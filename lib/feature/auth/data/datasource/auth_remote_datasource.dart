import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';

import '../../domain/entities/forgot_password_request.dart';
import '../../domain/entities/login_request.dart';
import '../../domain/entities/register_request.dart';

/// Generates a random 32-character hex string to use as a social_id
/// for email-based auth (the API requires a non-empty social_id even
/// for standard email registrations).
String _generateSocialId() {
  final rng = Random.secure();
  return List.generate(32, (_) => rng.nextInt(16).toRadixString(16)).join();
}

/// Maps DaySelector abbreviation → API key.
const _dayKeyMap = {
  'M': 'mon',
  'T': 'tue',
  'W': 'wed',
  'Th': 'thu',
  'F': 'fri',
  'S': 'sat',
  'Su': 'sun',
};

abstract class AuthRemoteDataSource {
  Future<void> register(RegisterRequest request);
  Future<Map<String, dynamic>> login(LoginRequest request);
  Future<void> forgotPassword(ForgotPasswordRequest request);
  Future<Map<String, dynamic>> verifyOtp(VerifyOtpRequest request);
  Future<void> resetPassword(ResetPasswordRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  const AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<void> register(RegisterRequest request) async {
    // ── Build business_hours with API day keys ───────────────────
    final apiHours = <String, List<String>>{};
    for (final entry in request.businessHours.entries) {
      final apiKey = _dayKeyMap[entry.key] ?? entry.key.toLowerCase();
      if (entry.value.isNotEmpty) apiHours[apiKey] = entry.value;
    }

    // ── social_id ────────────────────────────────────────────────
    // The Swagger spec shows social_id as a token string like
    // "0imfnc8mVLWwsAawjYr4Rx-Af50DDqtlx". For email auth we generate one;
    // for social logins the OAuth provider ID is used.
    final socialId = (request.type == 'email')
        ? _generateSocialId()
        : (request.socialId.isNotEmpty
              ? request.socialId
              : _generateSocialId());

    // ── Send as JSON — exact format from API spec ─────────────
    // All fields are required. device_token must be non-empty;
    // use a placeholder when a real FCM token isn’t available.
    final deviceToken = request.deviceToken.isNotEmpty
        ? request.deviceToken
        : 'no-device-token';

    final response = await _dio.post(
      'user/register',
      data: {
        'full_name': request.fullName,
        'email': request.email,
        'phone': request.phone,
        'password': request.password,
        'role': request.role,
        'business_name': request.businessName,
        'informal_name': request.informalName,
        'address': request.address,
        'city': request.city,
        'state': request.state,
        'zip_code': request.zipCode, // integer
        'registration_proof': request.registrationProofName, // filename string
        'business_hours': apiHours, // nested Map object
        'device_token': deviceToken,
        'type': request.type,
        'social_id': socialId,
      },
      options: Options(
        responseType: ResponseType.plain,
        validateStatus: (status) => status != null,
      ),
    );

    final statusCode = response.statusCode ?? 0;
    final rawBody = (response.data as String?) ?? '';

    // The server sometimes prepends a PHP warning before the JSON
    // e.g. "Sorry, there was an error uploading your file.{...}"
    // Strip everything before the first '{' so we can parse cleanly.
    final jsonStart = rawBody.indexOf('{');
    final cleanBody = jsonStart >= 0 ? rawBody.substring(jsonStart) : rawBody;

    // Always try to parse the body — the API returns HTTP 200 even on failure.
    Map<String, dynamic>? body;
    try {
      body = Map<String, dynamic>.from(jsonDecode(cleanBody) as Map);
    } catch (_) {
      // Body wasn't valid JSON — only fail if HTTP status was also bad.
    }

    if (statusCode != 200 && statusCode != 201) {
      final message =
          body?['message']?.toString() ??
          'Registration failed (HTTP $statusCode)';
      throw Exception(message);
    }

    // HTTP 200/201 but API reported failure.
    // NOTE: The API returns success as a string ("true"/"false"), not a bool.
    final successVal = body?['success'];
    final isFailure =
        successVal == false || successVal == 'false' || successVal == null;
    if (body != null && isFailure) {
      final message = body['message']?.toString() ?? 'Registration failed';
      throw Exception(message);
    }
  }

  @override
  Future<Map<String, dynamic>> login(LoginRequest request) async {
    final deviceToken = request.deviceToken.isNotEmpty
        ? request.deviceToken
        : 'no-device-token';

    final response = await _dio.post(
      'user/login',
      data: {
        'email': request.email,
        'password': request.password,
        'role': request.role,
        'device_token': deviceToken,
        'type': request.type,
        // For email auth use email as social_id — API requires non-empty value
        'social_id': request.socialId.isNotEmpty
            ? request.socialId
            : request.email,
      },
      options: Options(
        // JSON body — Dio sets Content-Type: application/json automatically
        responseType: ResponseType.plain,
        validateStatus: (status) => status != null,
      ),
    );

    final statusCode = response.statusCode ?? 0;
    final rawBody = (response.data as String?) ?? '';
    // Strip any PHP warning text prepended before the JSON object
    final jsonStart = rawBody.indexOf('{');
    final cleanBody = jsonStart >= 0 ? rawBody.substring(jsonStart) : rawBody;

    late Map<String, dynamic> body;
    try {
      body = Map<String, dynamic>.from(jsonDecode(cleanBody) as Map);
    } catch (_) {
      throw Exception('Unexpected server response');
    }

    if (statusCode != 200 && statusCode != 201) {
      throw Exception(
        body['message']?.toString() ?? 'Login failed (HTTP $statusCode)',
      );
    }

    // HTTP 200/201 but API reported failure (e.g. "Account does not exist.").
    // NOTE: The API returns success as a string ("true"/"false"), not a bool.
    final successVal = body['success'];
    if (successVal == false || successVal == 'false') {
      throw Exception(body['message']?.toString() ?? 'Login failed');
    }

    return body;
  }

  // ── Helper: post JSON, strip PHP prefix, decode response ─────────────
  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post(
      path,
      data: data,
      options: Options(
        responseType: ResponseType.plain,
        validateStatus: (status) => status != null,
      ),
    );
    final rawBody = (response.data as String?) ?? '';
    final jsonStart = rawBody.indexOf('{');
    final cleanBody = jsonStart >= 0 ? rawBody.substring(jsonStart) : rawBody;
    late Map<String, dynamic> body;
    try {
      body = Map<String, dynamic>.from(jsonDecode(cleanBody) as Map);
    } catch (_) {
      throw Exception('Unexpected server response');
    }

    // Check HTTP status
    if ((response.statusCode ?? 0) != 200 &&
        (response.statusCode ?? 0) != 201) {
      throw Exception(body['message']?.toString() ?? 'Request failed');
    }

    // Check API 'success' field — the API returns HTTP 200 even on functional failures
    // (e.g., "Couldn't send an OTP", "Invalid OTP").
    final success = body['success'];
    if (success == false || success == 'false') {
      throw Exception(body['message']?.toString() ?? 'Operation failed');
    }

    return body;
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    await _postJson('user/forgot-password', {'mobile': request.mobile});
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(VerifyOtpRequest request) async {
    return _postJson('user/verify-otp', {'otp': request.otp});
  }

  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {
    await _postJson('user/reset-password', {
      'token': request.token,
      'password': request.password,
      'cpassword': request.cpassword,
    });
  }
}
