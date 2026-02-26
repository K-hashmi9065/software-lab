import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:software_lab_task/core/constant/colors.dart';

class OtpField extends StatefulWidget {
  final int length;
  final void Function(String otp) onChanged;
  final void Function(String otp)? onCompleted;
  final double height;
  final double gap;
  final double borderRadius;
  final double fontSize;

  const OtpField({
    super.key,
    this.length = 5,
    required this.onChanged,
    this.onCompleted,
    this.height = 58,
    this.gap = 12,
    this.borderRadius = 8,
    this.fontSize = 20,
  });

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste — distribute digits across boxes
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < widget.length && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final nextEmpty = _controllers.indexWhere((c) => c.text.isEmpty);
      if (nextEmpty != -1) {
        _focusNodes[nextEmpty].requestFocus();
      } else {
        _focusNodes.last.unfocus();
      }
    } else if (value.isNotEmpty) {
      // Single digit entered — move to next
      if (index + 1 < widget.length) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    widget.onChanged(_currentOtp);

    if (_currentOtp.length == widget.length && !_currentOtp.contains('')) {
      widget.onCompleted?.call(_currentOtp);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build: [Expanded box] [gap] [Expanded box] [gap] ... [Expanded box]
    return Row(
      children: List.generate(widget.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Gap between boxes
          return SizedBox(width: widget.gap.w);
        }

        final index = i ~/ 2;
        return Expanded(
          child: SizedBox(
            height: widget.height.h,
            child: KeyboardListener(
              focusNode: FocusNode(skipTraversal: true),
              onKeyEvent: (event) {
                // Backspace on empty box → go to previous
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace &&
                    _controllers[index].text.isEmpty &&
                    index > 0) {
                  _focusNodes[index - 1].requestFocus();
                  _controllers[index - 1].clear();
                  widget.onChanged(_currentOtp);
                }
              },
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.beVietnamPro(
                  fontSize: widget.fontSize.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                  height: 1.0,
                ),
                onChanged: (val) => _onDigitChanged(index, val),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.primaryText.withValues(alpha: 0.08),
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius.r),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
