import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constant/colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/custom_button.dart';
import '../provider/forgot_password_provider.dart';
import '../widgets/otp_field.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _otp = '';

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

  Future<void> _onSubmit() async {
    if (_otp.length < 5) {
      _showError('Please enter the complete OTP');
      return;
    }

    await ref.read(forgotPasswordProvider.notifier).verifyOtp(_otp);
    if (!mounted) return;

    // Read result ONCE right after await — no listener needed
    final s = ref.read(forgotPasswordProvider);
    if (s.errorMessage != null) {
      _showError(s.errorMessage!);
      ref.read(forgotPasswordProvider.notifier).clearEvent();
    } else if (s.isSuccess && s.resetToken.isNotEmpty) {
      ref.read(forgotPasswordProvider.notifier).clearEvent();
      context.push(AppRoutes.resetPassword);
    }
  }

  Future<void> _onResend() async {
    final mobile = ref.read(forgotPasswordProvider).mobile;
    if (mobile.isEmpty) return;

    await ref.read(forgotPasswordProvider.notifier).sendCode(mobile);
    if (!mounted) return;

    // Only clear the event — don't navigate, we're already on the OTP screen
    ref.read(forgotPasswordProvider.notifier).clearEvent();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
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
                "Verify OTP",
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
              SizedBox(height: 71.h),
              OtpField(
                length: 5,
                onChanged: (otp) => _otp = otp,
                onCompleted: (otp) {
                  _otp = otp;
                  _onSubmit();
                },
              ),
              SizedBox(height: 30.h),
              CustomButton(
                label: 'Submit',
                isLoading: state.isLoading,
                onPressed: _onSubmit,
              ),
              SizedBox(height: 25.h),
              Center(
                child: GestureDetector(
                  onTap: state.isLoading ? null : _onResend,
                  child: Text(
                    'Resend Code',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                      letterSpacing: 0,
                      color: AppColors.primaryText,
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.solid,
                      decorationColor: AppColors.primaryText,
                      decorationThickness: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
