import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constant/colors.dart';

/// A horizontal row of day-of-week chips.
///
/// Border rules:
/// - **Focused** day           → Primary fill + Primary border
/// - **Has saved slots** day   → Light gray fill + **No border**
/// - **Default** day           → Light gray fill + Dark gray border
class DaySelector extends StatelessWidget {
  static const List<String> _days = ['M', 'T', 'W', 'Th', 'F', 'S', 'Su'];

  /// The day currently focused (primary colour). Null = none.
  final String? focusedDay;

  /// Days that already have at least one time slot saved.
  /// These will have their border removed.
  final Set<String> daysWithSlots;

  /// Called when any chip is tapped.
  final void Function(String day) onDayTap;

  const DaySelector({
    super.key,
    this.focusedDay,
    this.daysWithSlots = const {},
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _days
          .map(
            (day) => _DayChip(
              label: day,
              isFocused: focusedDay == day,
              hasSlots: daysWithSlots.contains(day),
              onTap: () => onDayTap(day),
            ),
          )
          .toList(),
    );
  }
}

// ── Private chip ─────────────────────────────────────────────────────────────

class _DayChip extends StatelessWidget {
  final String label;
  final bool isFocused;

  /// True if this day has at least one time slot saved.
  final bool hasSlots;

  final VoidCallback onTap;

  static const Color _inactiveBg = Color(0xFFF0F0F0);
  static const Color _inactiveBorder = Color(0xFF9E9E9E);

  const _DayChip({
    required this.label,
    required this.isFocused,
    required this.hasSlots,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Border logic:
    // focused          → primary border
    // has slots        → no border
    // default (neither) → dark gray border
    final Border? border = isFocused
        ? Border.all(color: AppColors.primary, width: 1.5)
        : hasSlots
        ? null // ← no border when time is selected
        : Border.all(color: _inactiveBorder, width: 1.5);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: isFocused ? AppColors.primary : _inactiveBg,
          borderRadius: BorderRadius.circular(10.r),
          border: border,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.beVietnamPro(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            height: 1.0,
            color: isFocused ? AppColors.white : AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}
