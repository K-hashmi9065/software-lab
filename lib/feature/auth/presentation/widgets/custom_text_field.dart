import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:software_lab_task/core/constant/colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final String? svgIconPath;
  final IconData? iconData;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.svgIconPath,
    this.iconData,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h, // Height: 48px
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        readOnly: readOnly,
        maxLines: maxLines,
        onChanged: onChanged,
        validator: validator,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.beVietnamPro(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryText,
          height: 1.0,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.beVietnamPro(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.secondaryText,
            height: 1.0,
            letterSpacing: 0,
          ),
          // Prefix icon — supports both SVG asset and IconData
          prefixIcon: svgIconPath != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: SvgPicture.asset(
                    svgIconPath!,
                    width: 20.w,
                    height: 20.h,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryText,
                      BlendMode.srcIn,
                    ),
                  ),
                )
              : iconData != null
              ? Icon(iconData, size: 20.sp, color: AppColors.primaryText)
              : null,
          prefixIconConstraints: BoxConstraints(
            minWidth: 48.w,
            minHeight: 48.h,
          ),
          suffixIconConstraints: BoxConstraints(minHeight: 48.h),
          suffixIcon: suffixIcon,
          // Fill: primaryText at 8% opacity, radius 8px, no border
          filled: true,
          fillColor: AppColors.primaryText.withValues(alpha: 0.08),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
      ),
    );
  }
}
