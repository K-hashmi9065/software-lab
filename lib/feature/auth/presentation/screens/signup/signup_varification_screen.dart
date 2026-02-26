import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
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

class SignupVerificationScreen extends ConsumerStatefulWidget {
  const SignupVerificationScreen({super.key});

  @override
  ConsumerState<SignupVerificationScreen> createState() =>
      _SignupVerificationScreenState();
}

class _SignupVerificationScreenState
    extends ConsumerState<SignupVerificationScreen> {
  final List<PlatformFile> _files = [];

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: false,
        withData:
            true, // loads bytes into memory — avoids content:// URI issues
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return;

      // Guard against large files that exceed the server's post_max_size.
      // When PHP's post_max_size is exceeded it silently empties $_POST,
      // causing every field (including social_id) to appear missing.
      const maxBytes = 500 * 1024; // 500 KB — safe limit for this server
      if (bytes.length > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'File too large. Please choose a file smaller than 500 KB '
                '(use a compressed image or a short PDF).',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      setState(() => _files.add(file));

      // Always keep the first file as the proof sent to the API
      if (_files.length == 1) {
        ref
            .read(registerProvider.notifier)
            .setRegistrationProof(bytes: bytes, fileName: file.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open file picker. Check storage permissions.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() => _files.removeAt(index));
    // Update provider: first remaining file becomes the proof, or clear
    if (_files.isNotEmpty) {
      final first = _files.first;
      final bytes = first.bytes;
      if (bytes != null) {
        ref
            .read(registerProvider.notifier)
            .setRegistrationProof(bytes: bytes, fileName: first.name);
      }
    } else {
      ref
          .read(registerProvider.notifier)
          .setRegistrationProof(bytes: Uint8List(0), fileName: '');
    }
  }

  void _onContinue() {
    if (_files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please attach at least one proof document'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    context.push(AppRoutes.signupHours);
  }

  @override
  Widget build(BuildContext context) {
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
                      "Signup 3 of 4",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                        letterSpacing: 0,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      "Verification",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 35.h),
                    Text(
                      "Attached proof of Department of Agriculture registrations i.e. Florida Fresh, USDA Approved, USDA Organic",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                        letterSpacing: 0,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    SizedBox(height: 35.h),

                    // ── Upload row ────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Attach proof of registration",
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            letterSpacing: 0,
                            color: AppColors.primaryText,
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickFile,
                          child: Container(
                            width: 53.w,
                            height: 53.h,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                AppAssets.cameraSvg,
                                width: 22.w,
                                height: 22.h,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── File list ─────────────────────────────────────
                    if (_files.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      ...List.generate(_files.length, (i) {
                        final file = _files[i];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Text(
                                    file.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _removeFile(i),
                                  child: SvgPicture.asset(
                                    AppAssets.crossCut,
                                    width: 18.w,
                                    height: 18.h,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.primaryText,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 30.w, right: 30.w, bottom: 24.h),
              child: Row(
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
            ),
          ],
        ),
      ),
    );
  }
}
