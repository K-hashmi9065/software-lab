import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constant/assets.dart';
import '../../../../../core/constant/colors.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/utils/custom_button.dart';
import '../../provider/register_provider.dart';

class SignupConfirmScreen extends ConsumerStatefulWidget {
  const SignupConfirmScreen({super.key});

  @override
  ConsumerState<SignupConfirmScreen> createState() =>
      _SignupConfirmScreenState();
}

class _SignupConfirmScreenState extends ConsumerState<SignupConfirmScreen> {
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    // Auto-submit once when this screen first mounts
    WidgetsBinding.instance.addPostFrameCallback((_) => _submit());
  }

  Future<void> _submit() async {
    if (_submitted) return;
    _submitted = true;
    await ref.read(registerProvider.notifier).submit();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerProvider);

    // Show error and allow retry
    if (state.errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Spacer(),
              Icon(
                Icons.error_outline,
                size: 72.sp,
                color: AppColors.secondaryText,
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                    height: 1.6,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(left: 23.w, right: 23.w, bottom: 24.h),
                child: CustomButton(
                  label: 'Try Again',
                  onPressed: () {
                    _submitted = false;
                    _submit();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Loading while submitting
    if (state.isLoading || !state.isSuccess) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // Success screen
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 215.h),
            SvgPicture.asset(AppAssets.greenTick),
            SizedBox(height: 55.h),
            Text(
              "You're all done!",
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                height: 1.0,
                letterSpacing: 0,
                color: AppColors.primaryText,
              ),
            ),
            SizedBox(height: 35.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 21.w),
              child: Text(
                "Hang tight!  We are currently reviewing your account and will follow up with you in 2-3 business days. In the meantime, you can setup your inventory.",
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                  letterSpacing: 0,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(left: 23.w, right: 23.w, bottom: 24.h),
              child: CustomButton(
                label: 'Got it!',
                onPressed: () => context.go(AppRoutes.login),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
