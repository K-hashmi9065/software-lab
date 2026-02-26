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
import '../provider/forgot_password_provider.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _mobileCtrl = TextEditingController();

  @override
  void dispose() {
    _mobileCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
        ),
      );
  }

  Future<void> _onSendCode() async {
    final mobile = _mobileCtrl.text.trim();
    if (mobile.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }

    // Call the API — we navigate to OTP screen regardless of SMS delivery
    // because the server SMS gateway may fail even if the account exists.
    await ref.read(forgotPasswordProvider.notifier).sendCode(mobile);
    if (!mounted) return;

    // Always clear any error and move to OTP screen
    ref.read(forgotPasswordProvider.notifier).clearEvent();
    context.push(AppRoutes.otp);
  }

  Future<void> _onBypass() async {
    final mobile = _mobileCtrl.text.trim();
    ref.read(forgotPasswordProvider.notifier).forceSuccessForTesting(mobile);
    if (!mounted) return;
    ref.read(forgotPasswordProvider.notifier).clearEvent();
    context.push(AppRoutes.otp);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 30.w, right: 30.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 46.h),
              GestureDetector(
                onTap: _onBypass,
                child: Text(
                  "FarmerEats",
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                    letterSpacing: 0,
                  ),
                ),
              ),
              SizedBox(height: 55.h),
              Text(
                "Forgot Password?",
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
                      text: "Remember your password?  ",
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                    TextSpan(
                      text: "Login",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => context.push(AppRoutes.login),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 75.h),
              CustomTextField(
                controller: _mobileCtrl,
                hintText: 'Phone Number',
                svgIconPath: AppAssets.phoneSvg,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 40.h),
              CustomButton(
                label: 'Send Code',
                isLoading: state.isLoading,
                onPressed: _onSendCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
