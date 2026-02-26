import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/entities/forgot_password_request.dart';

// ── Dependency wiring ─────────────────────────────────────────────────────────

final _dioProvider = Provider((_) => DioClient.instance);
final _dsProvider = Provider(
  (ref) => AuthRemoteDataSourceImpl(ref.read(_dioProvider)),
);
final _repoProvider = Provider(
  (ref) => AuthRepositoryImpl(ref.read(_dsProvider)),
);
final _repoInterfaceProvider = Provider<AuthRepositoryImpl>(
  (ref) => ref.read(_repoProvider),
);

// ── State ─────────────────────────────────────────────────────────────────────

/// Shared state across the 3-screen forgot-password flow.
/// [errorMessage] and [isSuccess] are ONE-SHOT events:
/// the UI clears them via [clearEvent] immediately after consuming them,
/// which prevents duplicate snackbars on rebuilds.
class ForgotPasswordState {
  final bool isLoading;

  /// One-shot error message — cleared after the UI consumes it.
  final String? errorMessage;

  /// One-shot success flag — cleared after the UI navigates.
  final bool isSuccess;

  /// Set after step 1 succeeds — displayed in the OTP screen subtitle.
  final String mobile;

  /// Set after step 2 succeeds — forwarded to reset-password screen.
  final String resetToken;

  const ForgotPasswordState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.mobile = '',
    this.resetToken = '',
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearEvent = false, // clears BOTH errorMessage and isSuccess
    bool? isSuccess,
    String? mobile,
    String? resetToken,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearEvent ? null : (errorMessage ?? this.errorMessage),
      isSuccess: clearEvent ? false : (isSuccess ?? this.isSuccess),
      mobile: mobile ?? this.mobile,
      resetToken: resetToken ?? this.resetToken,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  final AuthRepositoryImpl _repo;
  ForgotPasswordNotifier(this._repo) : super(const ForgotPasswordState());

  /// Step 1 — POST /user/forgot-password  { "mobile": "..." }
  Future<void> sendCode(String mobile) async {
    state = state.copyWith(isLoading: true, clearEvent: true, mobile: mobile);
    try {
      await _repo.forgotPassword(ForgotPasswordRequest(mobile: mobile));
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on Exception catch (e) {
      // Still save the mobile and mark loading done — UI will navigate anyway
      state = state.copyWith(
        isLoading: false,
        mobile: mobile,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Step 2 — POST /user/verify-otp  { "otp": "..." }  → returns token
  Future<void> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, clearEvent: true);
    try {
      final response = await _repo.verifyOtp(VerifyOtpRequest(otp: otp));
      // Per API docs the token field IS the OTP string on this test server.
      final token = response['token']?.toString() ?? otp;
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        resetToken: token,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Step 3 — POST /user/reset-password  { "token", "password", "cpassword" }
  Future<void> resetPassword({
    required String password,
    required String cpassword,
  }) async {
    state = state.copyWith(isLoading: true, clearEvent: true);
    try {
      await _repo.resetPassword(
        ResetPasswordRequest(
          token: state.resetToken,
          password: password,
          cpassword: cpassword,
        ),
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Called by the UI immediately after consuming an event, so it is
  /// never re-triggered on the next rebuild.
  void clearEvent() => state = state.copyWith(clearEvent: true);

  /// DEVELOPMENT BYPASS:
  /// Tap the "FarmerEats" title on the Forgot Password screen to bypass
  /// the SMS gateway and jump straight to the OTP screen.
  void forceSuccessForTesting(String mobile) {
    state = state.copyWith(
      isLoading: false,
      isSuccess: true,
      mobile: mobile.isEmpty ? '+10000000000' : mobile,
      clearEvent: false,
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final forgotPasswordProvider =
    StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>(
      (ref) => ForgotPasswordNotifier(ref.read(_repoInterfaceProvider)),
    );
