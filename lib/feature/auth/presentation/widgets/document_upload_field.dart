import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constant/assets.dart';
import '../../../../core/constant/colors.dart';

class DocumentUploadField extends StatefulWidget {
  /// Label shown on the left side of the camera button row.
  final String label;

  /// Called whenever the selected file changes (null = removed).
  final void Function(PlatformFile? file)? onChanged;

  const DocumentUploadField({super.key, required this.label, this.onChanged});

  @override
  State<DocumentUploadField> createState() => _DocumentUploadFieldState();
}

class _DocumentUploadFieldState extends State<DocumentUploadField> {
  PlatformFile? _selectedFile;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: false,
      );

      // result is null when the user cancels — do nothing
      if (result == null || result.files.isEmpty) return;

      setState(() => _selectedFile = result.files.first);
      widget.onChanged?.call(_selectedFile);
    } catch (e) {
      // Catches MissingPluginException, permission denials, etc.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open file picker. Please check storage permissions.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      debugPrint('[DocumentUploadField] _pickFile error: $e');
    }
  }

  void _removeFile() {
    setState(() => _selectedFile = null);
    widget.onChanged?.call(null);
  }

  /// Returns the right icon based on file extension.
  IconData _fileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //  Label + Camera button row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.label,
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

        // Selected file preview card
        if (_selectedFile != null) ...[
          SizedBox(height: 14.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                // File type icon
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    _fileIcon(_selectedFile!.extension),
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),

                // File name + size
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFile!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryText,
                        ),
                      ),
                      if (_selectedFile!.size > 0)
                        Text(
                          _formatBytes(_selectedFile!.size),
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.secondaryText,
                          ),
                        ),
                    ],
                  ),
                ),

                // Remove button
                GestureDetector(
                  onTap: _removeFile,
                  child: SvgPicture.asset(
                    AppAssets.crossCut,
                    width: 18.w,
                    height: 18.h,
                    colorFilter: const ColorFilter.mode(
                      AppColors.secondaryText,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
