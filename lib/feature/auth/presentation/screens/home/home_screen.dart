import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constant/colors.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../provider/login_provider.dart';
import '../../provider/register_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    final userData = loginState.responseData;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Welcome Home!',
          style: GoogleFonts.beVietnamPro(
            fontWeight: FontWeight.w600,
            fontSize: 26.sp,
            color: AppColors.primary,
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 28.sp, color: Colors.red),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: 10.h),
              Text(
                'User Details:',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 15.h),
              Expanded(
                child: userData == null || userData.isEmpty
                    ? Center(
                        child: Text(
                          'No user information available',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: userData.length,
                        separatorBuilder: (context, index) =>
                            Divider(color: Colors.grey.shade300, height: 25.h),
                        itemBuilder: (context, index) {
                          final key = userData.keys.elementAt(index);
                          final value = userData[key];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                key.replaceAll('_', ' ').toUpperCase(),
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  value.toString(),
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryText.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(
          'Log out?',
          style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.beVietnamPro(color: AppColors.secondaryText),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.beVietnamPro(color: AppColors.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Log out',
              style: GoogleFonts.beVietnamPro(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Clear login state (includes token & user data)
      await ref.read(loginProvider.notifier).logout();
      // Reset registration flow too
      ref.invalidate(registerProvider);
      // Navigate to login, clearing the entire back stack
      if (context.mounted) context.go(AppRoutes.login);
    }
  }
}
