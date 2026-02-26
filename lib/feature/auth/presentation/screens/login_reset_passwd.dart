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

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
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

  Future<void> _onSubmit() async {
    final pass = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (pass.isEmpty || confirm.isEmpty) {
      _showError('Please fill both password fields');
      return;
    }
    if (pass != confirm) {
      _showError('Passwords do not match');
      return;
    }

    await ref
        .read(forgotPasswordProvider.notifier)
        .resetPassword(password: pass, cpassword: confirm);
    if (!mounted) return;

    // Read result ONCE right after await — no listener needed
    final s = ref.read(forgotPasswordProvider);
    if (s.errorMessage != null) {
      _showError(s.errorMessage!);
      ref.read(forgotPasswordProvider.notifier).clearEvent();
    } else if (s.isSuccess) {
      ref.read(forgotPasswordProvider.notifier).clearEvent();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Password reset successful! Please login.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      context.go(AppRoutes.login);
    }
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
                "Reset Password",
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
                        ..onTap = () => context.go(AppRoutes.login),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 75.h),
              CustomTextField(
                controller: _passwordCtrl,
                hintText: 'New Password',
                svgIconPath: AppAssets.lockPass,
                keyboardType: TextInputType.text,
                obscureText: true,
              ),
              SizedBox(height: 25.h),
              CustomTextField(
                controller: _confirmCtrl,
                hintText: 'Confirm New Password',
                svgIconPath: AppAssets.lockPass,
                keyboardType: TextInputType.text,
                obscureText: true,
              ),
              SizedBox(height: 40.h),
              CustomButton(
                label: 'Submit',
                isLoading: state.isLoading,
                onPressed: _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
