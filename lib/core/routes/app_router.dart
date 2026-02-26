import 'package:go_router/go_router.dart';
import 'package:software_lab_task/core/routes/app_routes.dart';
import 'package:software_lab_task/feature/auth/presentation/screens/login_screen.dart';
import 'package:software_lab_task/feature/onbording/screens/onboarding_screen.dart';

import '../../feature/auth/presentation/screens/login_forgot_passwd.dart';
import '../../feature/auth/presentation/screens/login_otp.dart';
import '../../feature/auth/presentation/screens/login_reset_passwd.dart';
import '../../feature/auth/presentation/screens/signup/signup_confirm_screen.dart';
import '../../feature/auth/presentation/screens/signup/signup_form_screen.dart';
import '../../feature/auth/presentation/screens/signup/signup_hours_screen.dart';
import '../../feature/auth/presentation/screens/signup/signup_screen.dart';
import '../../feature/auth/presentation/screens/signup/signup_varification_screen.dart';
import '../../feature/auth/presentation/screens/home/home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.onboarding,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppRoutes.signupConfirm,
      name: 'signup-confirm',
      builder: (context, state) => const SignupConfirmScreen(),
    ),
    GoRoute(
      path: AppRoutes.signupHours,
      name: 'signup-hours',
      builder: (context, state) => const SignupHoursScreen(),
    ),
    GoRoute(
      path: AppRoutes.signupVerification,
      name: 'signup-verification',
      builder: (context, state) => const SignupVerificationScreen(),
    ),
    GoRoute(
      path: AppRoutes.signupForm,
      name: 'signup-form',
      builder: (context, state) => const SignupFormScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      name: 'otp',
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      name: 'reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
