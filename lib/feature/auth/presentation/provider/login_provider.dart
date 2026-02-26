import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/entities/login_request.dart';
import '../../domain/usecase/login_usecase.dart';

// ── Dependency providers ──────────────────────────────────────────────────────

final _dioProvider = Provider((_) => DioClient.instance);

final _dataSourceProvider = Provider(
  (ref) => AuthRemoteDataSourceImpl(ref.read(_dioProvider)),
);

final _repositoryProvider = Provider(
  (ref) => AuthRepositoryImpl(ref.read(_dataSourceProvider)),
);

final _loginUseCaseProvider = Provider(
  (ref) => LoginUseCase(ref.read(_repositoryProvider)),
);

// ── State ─────────────────────────────────────────────────────────────────────

class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final Map<String, dynamic>? responseData;
  final String? socialEmail;
  final String? socialName;
  final String? socialId;
  final String? socialType;

  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.responseData,
    this.socialEmail,
    this.socialName,
    this.socialId,
    this.socialType,
  });

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isSuccess,
    Map<String, dynamic>? responseData,
    String? socialEmail,
    String? socialName,
    String? socialId,
    String? socialType,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
      responseData: responseData ?? this.responseData,
      socialEmail: socialEmail ?? this.socialEmail,
      socialName: socialName ?? this.socialName,
      socialId: socialId ?? this.socialId,
      socialType: socialType ?? this.socialType,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class LoginNotifier extends StateNotifier<LoginState> {
  final LoginUseCase _useCase;
  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  LoginNotifier(this._useCase) : super(const LoginState());

  // ─────────────────────────────────────────
  // Logout
  // ─────────────────────────────────────────
  Future<void> logout() async {
    // Call signOut() directly — it's a no-op when not signed in,
    // and avoids triggering Google's SignInHubActivity UI flash.
    try {
      await _googleSignIn.signOut();
      // ignore: empty_catches
    } catch (_) {}
    try {
      await fb.FacebookAuth.instance.logOut();
      // ignore: empty_catches
    } catch (_) {}

    // Reset state completely — clears token, user data, everything
    state = const LoginState();
  }

  // ─────────────────────────────────────────
  // Email Login
  // ─────────────────────────────────────────
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    try {
      final request = LoginRequest(
        email: email,
        password: password,
        role: 'farmer',
        type: 'email',
        // email is used as social_id for email auth
        socialId: email,
      );

      final data = await _useCase(request);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        responseData: data,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ─────────────────────────────────────────
  // Social Login
  // ─────────────────────────────────────────
  Future<void> socialLogin({required String type}) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    try {
      String? email;
      String? socialId;

      if (type == 'google') {
        // Force account selection by signing out first
        try {
          await _googleSignIn.signOut();
        } catch (_) {}

        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          state = state.copyWith(isLoading: false);
          return;
        }
        email = googleUser.email;
        socialId = googleUser.id;
        state = state.copyWith(
          socialEmail: googleUser.email,
          socialName: googleUser.displayName,
          socialId: googleUser.id,
          socialType: 'google',
        );
      } else if (type == 'facebook') {
        final fb.LoginResult result = await fb.FacebookAuth.instance.login(
          permissions: ['public_profile', 'email'],
        );
        if (result.status == fb.LoginStatus.success) {
          final userData = await fb.FacebookAuth.instance.getUserData();
          email = userData['email'] as String?;
          socialId = userData['id'] as String?;
          state = state.copyWith(
            socialEmail: email,
            socialName: userData['name'] as String?,
            socialId: socialId,
            socialType: 'facebook',
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: result.message ?? 'Facebook login failed',
          );
          return;
        }
      } else if (type == 'apple') {
        try {
          final appleCredential = await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );
          email = appleCredential.email;
          socialId = appleCredential.userIdentifier;
        } catch (e) {
          state = state.copyWith(isLoading: false);
          return;
        }
      }

      if (email == null || socialId == null) {
        throw Exception('Failed to get user details from $type');
      }

      final request = LoginRequest(
        email: email,
        password:
            'password', // social login usually doesn't need password on our side
        role: 'farmer',
        type: type,
        socialId: socialId,
      );

      final data = await _useCase(request);

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Login failed');
      }

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        responseData: data,
      );
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');

      if (errorMessage.contains('Type not matched')) {
        errorMessage =
            'This account uses a different login method (e.g., Email or Facebook). '
            'Please use the method you used during signup.';
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Social login failed: $errorMessage',
      );
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(ref.read(_loginUseCaseProvider)),
);
