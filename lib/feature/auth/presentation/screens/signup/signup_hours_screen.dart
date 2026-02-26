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
import '../../widgets/business_hours_provider.dart';
import '../../widgets/day_selector.dart';
import '../../widgets/time_slot_selector.dart';

class SignupHoursScreen extends ConsumerWidget {
  const SignupHoursScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(businessHoursProvider);
    final notifier = ref.read(businessHoursProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Scrollable content ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 46.h),
                    // Brand
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
                    // Page counter
                    Text(
                      "Signup 4 of 4",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                        letterSpacing: 0,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    // Heading
                    Text(
                      "Business Hours",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 35.h),
                    // Sub-heading
                    Text(
                      "Choose the hours your farm is open for pickups. This will allow customers to order deliveries.",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                        letterSpacing: 0,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    SizedBox(height: 35.h),

                    // ── Day chips ─────────────────────────────────────
                    DaySelector(
                      focusedDay: state.focusedDay,
                      daysWithSlots: state.dayTimeSlots.entries
                          .where((e) => e.value.isNotEmpty)
                          .map((e) => e.key)
                          .toSet(),
                      onDayTap: notifier.tapDay,
                    ),

                    // ── Time slots (animates in when a day is focused) ─
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: state.focusedDay != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 24.h),
                                Text(
                                  _fullDayName(state.focusedDay!),
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.secondaryText,
                                    height: 1.0,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                TimeSlotSelector(
                                  selectedSlots: state.slotsFor(
                                    state.focusedDay!,
                                  ),
                                  onSlotTap: notifier.toggleSlot,
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            // ── Back + Continue — always pinned at bottom ────────────
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
                      onPressed: () {
                        // Save business hours into the shared register provider
                        final hours = ref
                            .read(businessHoursProvider)
                            .dayTimeSlots;
                        ref
                            .read(registerProvider.notifier)
                            .setBusinessHours(hours);
                        context.push(AppRoutes.signupConfirm);
                      },
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

  String _fullDayName(String abbr) {
    const map = {
      'M': 'Monday',
      'T': 'Tuesday',
      'W': 'Wednesday',
      'Th': 'Thursday',
      'F': 'Friday',
      'S': 'Saturday',
      'Su': 'Sunday',
    };
    return map[abbr] ?? abbr;
  }
}
