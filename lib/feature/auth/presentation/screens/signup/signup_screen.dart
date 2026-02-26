import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constant/assets.dart';
import '../../../../../core/constant/colors.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/utils/custom_button.dart';
import '../../provider/login_provider.dart';
import '../../provider/register_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/social_button.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _onContinue() {
    // Basic validation
    if (_fullNameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_passwordCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref
        .read(registerProvider.notifier)
        .setScreen1(
          fullName: _fullNameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
    context.push(AppRoutes.signupForm);
  }

  Future<void> _onSocialLogin(String type) async {
    await ref.read(loginProvider.notifier).socialLogin(type: type);
  }

  @override
  Widget build(BuildContext context) {
    // Listen for social login success or pre-fill info
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

      // If social login failed เพราะ account dose not exist -> pre-fill details
      if (next.errorMessage == 'Account does not exist.' &&
          next.socialEmail != null) {
        _fullNameCtrl.text = next.socialName ?? '';
        _emailCtrl.text = next.socialEmail ?? '';

        // Ensure the registration will use the correct social type
        ref
            .read(registerProvider.notifier)
            .setType(next.socialType ?? 'google', socialId: next.socialId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account not found. We\'ve pre-filled your details.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
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
                      "Signup 1 of 4",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        letterSpacing: 0,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      "Welcome!",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 38.h),

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
                    SizedBox(height: 41.h),
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
                    SizedBox(height: 35.h),

                    CustomTextField(
                      controller: _fullNameCtrl,
                      hintText: 'Full Name',
                      svgIconPath: AppAssets.personSvg,
                      keyboardType: TextInputType.name,
                    ),
                    SizedBox(height: 25.h),
                    CustomTextField(
                      controller: _emailCtrl,
                      hintText: 'Email Address',
                      svgIconPath: AppAssets.emailSvg,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 25.h),
                    CustomTextField(
                      controller: _phoneCtrl,
                      hintText: 'Phone Number',
                      svgIconPath: AppAssets.phoneSvg,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 25.h),
                    CustomTextField(
                      controller: _passwordCtrl,
                      hintText: 'Password',
                      svgIconPath: AppAssets.lockPass,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                    ),
                    SizedBox(height: 25.h),
                    CustomTextField(
                      controller: _confirmPassCtrl,
                      hintText: 'Re-enter Password',
                      svgIconPath: AppAssets.lockPass,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            // ── Pinned bottom row ─────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(left: 30.w, right: 30.w, bottom: 24.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => context.goNamed('login'),
                    child: Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText,
                        height: 1.0,
                        letterSpacing: 0,
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.solid,
                        decorationColor: AppColors.primaryText,
                        decorationThickness: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 215.w,
                    child: CustomButton(
                      label: 'Continue',
                      onPressed: _onContinue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
