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
import '../../widgets/custom_text_field.dart';

class SignupFormScreen extends ConsumerStatefulWidget {
  const SignupFormScreen({super.key});

  @override
  ConsumerState<SignupFormScreen> createState() => _SignupFormScreenState();
}

class _SignupFormScreenState extends ConsumerState<SignupFormScreen> {
  final _businessNameCtrl = TextEditingController();
  final _informalNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill if user navigated back
    final saved = ref.read(registerProvider);
    _businessNameCtrl.text = saved.businessName;
    _informalNameCtrl.text = saved.informalName;
    _addressCtrl.text = saved.address;
    _cityCtrl.text = saved.city;
    _stateCtrl.text = saved.state;
    _zipCtrl.text = saved.zipCode;
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _informalNameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_businessNameCtrl.text.trim().isEmpty ||
        _informalNameCtrl.text.trim().isEmpty ||
        _addressCtrl.text.trim().isEmpty ||
        _cityCtrl.text.trim().isEmpty ||
        _stateCtrl.text.trim().isEmpty ||
        _zipCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref
        .read(registerProvider.notifier)
        .setScreen2(
          businessName: _businessNameCtrl.text.trim(),
          informalName: _informalNameCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          stateValue: _stateCtrl.text.trim(),
          zipCode: _zipCtrl.text.trim(),
        );
    context.push(AppRoutes.signupVerification);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
                "Signup 2 of 4",
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
                "Farm Info",
                style: GoogleFonts.beVietnamPro(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 45.h),

              CustomTextField(
                controller: _businessNameCtrl,
                hintText: 'Business Name',
                svgIconPath: AppAssets.businessSvg,
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: 25.h),
              CustomTextField(
                controller: _informalNameCtrl,
                hintText: 'Informal Name',
                svgIconPath: AppAssets.informalNameSvg,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 25.h),
              CustomTextField(
                controller: _addressCtrl,
                hintText: 'Street Address',
                svgIconPath: AppAssets.addressSvg,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 25.h),
              CustomTextField(
                controller: _cityCtrl,
                hintText: 'City',
                svgIconPath: AppAssets.locationSvg,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 25.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 43,
                    child: SizedBox(
                      height: 46.h,
                      child: CustomTextField(
                        controller: _stateCtrl,
                        hintText: 'State',
                        keyboardType: TextInputType.text,
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 14.w),
                          child: Center(
                            widthFactor: 1,
                            child: GestureDetector(
                              onTap: () {},
                              child: SvgPicture.asset(
                                AppAssets.downButton,
                                width: 10.w,
                                height: 10.h,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    flex: 65,
                    child: SizedBox(
                      height: 48.h,
                      child: CustomTextField(
                        controller: _zipCtrl,
                        hintText: 'Enter Zipcode',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h),

              // ── Pinned button row ───────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: SvgPicture.asset(
                      AppAssets.backButton,
                      width: 22.w,
                      height: 22.h,
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
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
