import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialButton extends StatelessWidget {
  final String svgAssetPath;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final double borderRadius;
  final double iconSize;
  final Color borderColor;
  final Color backgroundColor;

  const SocialButton({
    super.key,
    required this.svgAssetPath,
    required this.onPressed,
    this.width,
    this.height = 52,
    this.borderRadius = 117,
    this.iconSize = 24,
    this.borderColor = const Color(0xFFE0E0E0),
    this.backgroundColor = const Color(0xFFFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius.r),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Center(
          child: SvgPicture.asset(
            svgAssetPath,
            width: iconSize.w,
            height: iconSize.h,
          ),
        ),
      ),
    );
  }
}
