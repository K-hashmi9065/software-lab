import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constant/assets.dart';
import '../../../../core/constant/colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/custom_button.dart';
import '../provider/login_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await ref
        .read(loginProvider.notifier)
        .login(email: email, password: password);
  }

  Future<void> _onSocialLogin(String type) async {
    await ref.read(loginProvider.notifier).socialLogin(type: type);
  }

  @override
  Widget build(BuildContext context) {
    // Listen for success / error side effects
    ref.listen<LoginState>(loginProvider, (_, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        context.go(AppRoutes.home);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    });

    final state = ref.watch(loginProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 30.w, right: 30.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 46.h),
                Text(
                  "FarmerEats",
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 55.h),
                Text(
                  "Welcome back!",
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 22.h),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                      letterSpacing: 0,
                    ),
                    children: [
                      TextSpan(
                        text: "New here?  ",
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                      TextSpan(
                        text: "Create account",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.push(AppRoutes.signup),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 75.h),

                // ── Email field ─────────────────────────────────────
                CustomTextField(
                  controller: _emailCtrl,
                  hintText: 'Email Address',
                  svgIconPath: AppAssets.emailSvg,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 25.h),

                // ── Password field ──────────────────────────────────
                CustomTextField(
                  controller: _passwordCtrl,
                  hintText: 'Password',
                  svgIconPath: AppAssets.lockPass,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  suffixIcon: GestureDetector(
                    onTap: () => context.push(AppRoutes.forgotPassword),
                    child: Padding(
                      padding: EdgeInsets.only(right: 14.w, top: 16.h),
                      child: Text(
                        'Forgot?',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primary,
                          height: 1.0,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 45.h),

                // ── Login button ────────────────────────────────────
                CustomButton(
                  label: 'Login',
                  isLoading: state.isLoading,
                  onPressed: _onLogin,
                ),

                SizedBox(height: 45.h),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Or continue with",
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                      height: 1.0,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                SizedBox(height: 40.h),

                // ── Social buttons ──────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SocialButton(
                      svgAssetPath: AppAssets.googleLogo,
                      onPressed: () => _onSocialLogin('google'),
                      width: 95.w,
                    ),
                    SizedBox(width: 16.w),
                    SocialButton(
                      svgAssetPath: AppAssets.appleLogo,
                      onPressed: () => _onSocialLogin('apple'),
                      width: 95.w,
                    ),
                    SizedBox(width: 16.w),
                    SocialButton(
                      svgAssetPath: AppAssets.facebookLogo,
                      onPressed: () => _onSocialLogin('facebook'),
                      width: 95.w,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
