import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constant/colors.dart';

/// Default time slots for the Business Hours screen.
const List<String> kDefaultTimeSlots = [
  '8:00am - 10:00am',
  '10:00am - 1:00pm',
  '1:00pm - 4:00pm',
  '4:00pm - 7:00pm',
  '7:00pm - 10:00pm',
];

/// A 2-column wrap of toggleable time-slot chips.
///
/// Controlled widget — state lives in [businessHoursProvider].
/// - **Selected** slot: Primary color background.
/// - **Unselected** slot: Light gray background.
class TimeSlotSelector extends StatelessWidget {
  /// Time-slot labels to display.
  final List<String> slots;

  /// Slots that are currently selected (for the focused day).
  final Set<String> selectedSlots;

  /// Called when a chip is tapped.
  final void Function(String slot) onSlotTap;

  const TimeSlotSelector({
    super.key,
    this.slots = kDefaultTimeSlots,
    this.selectedSlots = const {},
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chipWidth = (constraints.maxWidth - 12.w) / 2;
        return Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: slots
              .map(
                (slot) => _TimeSlotChip(
                  label: slot,
                  width: chipWidth,
                  isSelected: selectedSlots.contains(slot),
                  onTap: () => onSlotTap(slot),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

// ── Private chip ─────────────────────────────────────────────────────────────

class _TimeSlotChip extends StatelessWidget {
  final String label;
  final double width;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _unselectedBg = Color(0xFFF0F0F0);

  const _TimeSlotChip({
    required this.label,
    required this.width,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: width,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : _unselectedBg,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.beVietnamPro(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            height: 1.0,
            color: isSelected ? AppColors.white : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}
