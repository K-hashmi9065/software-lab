import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/entities/register_request.dart';
import '../../domain/usecase/register_usecase.dart';

// ── Dependency providers ──────────────────────────────────────────────────────

final _dioProvider = Provider((_) => DioClient.instance);

final _dataSourceProvider = Provider(
  (ref) => AuthRemoteDataSourceImpl(ref.read(_dioProvider)),
);

final _repositoryProvider = Provider(
  (ref) => AuthRepositoryImpl(ref.read(_dataSourceProvider)),
);

final _useCaseProvider = Provider(
  (ref) => RegisterUseCase(ref.read(_repositoryProvider)),
);

// ── Form state ────────────────────────────────────────────────────────────────

class RegisterFormState {
  // Screen 1
  final String fullName;
  final String email;
  final String phone;
  final String password;

  // Screen 2
  final String businessName;
  final String informalName;
  final String address;
  final String city;
  final String state;
  final String zipCode;

  // Screen 3 — bytes to avoid Android content:// URI issues
  final Uint8List? registrationProofBytes;
  final String registrationProofName;

  // Screen 4 — DaySelector labels: 'M','T','W','Th','F','S','Su'
  final Map<String, Set<String>> businessHours;

  // Extra API fields
  final String deviceToken;
  final String type;
  final String socialId;

  // Submission state
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const RegisterFormState({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.businessName = '',
    this.informalName = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.registrationProofBytes,
    this.registrationProofName = '',
    this.businessHours = const {},
    this.deviceToken = '',
    this.type = 'email',
    this.socialId = '',
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  RegisterFormState copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? password,
    String? businessName,
    String? informalName,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    Uint8List? registrationProofBytes,
    String? registrationProofName,
    Map<String, Set<String>>? businessHours,
    String? deviceToken,
    String? type,
    String? socialId,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isSuccess,
  }) {
    return RegisterFormState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      businessName: businessName ?? this.businessName,
      informalName: informalName ?? this.informalName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      registrationProofBytes:
          registrationProofBytes ?? this.registrationProofBytes,
      registrationProofName:
          registrationProofName ?? this.registrationProofName,
      businessHours: businessHours ?? this.businessHours,
      deviceToken: deviceToken ?? this.deviceToken,
      type: type ?? this.type,
      socialId: socialId ?? this.socialId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class RegisterNotifier extends StateNotifier<RegisterFormState> {
  final RegisterUseCase _useCase;
  RegisterNotifier(this._useCase) : super(const RegisterFormState());

  void setScreen1({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    state = state.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      clearError: true,
    );
  }

  void setScreen2({
    required String businessName,
    required String informalName,
    required String address,
    required String city,
    required String stateValue,
    required String zipCode,
  }) {
    state = state.copyWith(
      businessName: businessName,
      informalName: informalName,
      address: address,
      city: city,
      state: stateValue,
      zipCode: zipCode,
      clearError: true,
    );
  }

  void setRegistrationProof({
    required Uint8List bytes,
    required String fileName,
  }) {
    state = state.copyWith(
      registrationProofBytes: bytes,
      registrationProofName: fileName,
      clearError: true,
    );
  }

  void setBusinessHours(Map<String, Set<String>> hours) {
    state = state.copyWith(businessHours: hours, clearError: true);
  }

  void setType(String type, {String? socialId}) {
    state = state.copyWith(type: type, socialId: socialId, clearError: true);
  }

  Future<void> submit() async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    try {
      final bytes = state.registrationProofBytes;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Please attach a proof document before submitting.');
      }

      final request = RegisterRequest(
        fullName: state.fullName,
        email: state.email,
        phone: state.phone,
        password: state.password,
        role: 'farmer',
        businessName: state.businessName,
        informalName: state.informalName,
        address: state.address,
        city: state.city,
        state: state.state,
        zipCode: int.tryParse(state.zipCode) ?? 0,
        registrationProofBytes: bytes,
        registrationProofName: state.registrationProofName,
        businessHours: state.businessHours.map(
          (k, v) => MapEntry(k, v.toList()),
        ),
        deviceToken: state.deviceToken,
        type: state.type,
        // For email auth the API still requires social_id — use email
        socialId: state.socialId.isNotEmpty ? state.socialId : state.email,
      );

      await _useCase(request);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final registerProvider =
    StateNotifierProvider<RegisterNotifier, RegisterFormState>(
      (ref) => RegisterNotifier(ref.read(_useCaseProvider)),
    );
