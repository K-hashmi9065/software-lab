import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:software_lab_task/feature/onbording/models/onboarding_model.dart';
import 'package:software_lab_task/feature/onbording/providers/onboarding_provider.dart';
import '../../../core/constant/colors.dart';
import '../../../core/routes/app_routes.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    ref.read(currentPageProvider.notifier).state = index;
    _animController.reset();
    _animController.forward();
  }

  void _nextPage(BuildContext context, int currentPage, int totalPages) {
    if (currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      context.push(AppRoutes.signup);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingData = ref.watch(onboardingDataProvider);
    final currentPage = ref.watch(currentPageProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: onboardingData.length,
        itemBuilder: (context, index) {
          final data = onboardingData[index];
          final bgColor = getBackgroundColor(data.backgroundColor);
          return _OnboardingPage(
            data: data,
            backgroundColor: bgColor,
            currentPage: currentPage,
            totalPages: onboardingData.length,
            fadeAnimation: _fadeAnimation,
            slideAnimation: _slideAnimation,
            onNext: () => _nextPage(context, index, onboardingData.length),
          );
        },
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingModel data;
  final Color backgroundColor;
  final int currentPage;
  final int totalPages;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final VoidCallback onNext;

  const _OnboardingPage({
    required this.data,
    required this.backgroundColor,
    required this.currentPage,
    required this.totalPages,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final double cardTop = 470.h;
    return Stack(
      children: [
        //  Colored illustration background with images
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: cardTop + 52.r,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            color: backgroundColor,
            child: SvgPicture.asset(
              data.assetPath,
              fit: BoxFit.contain,
              width: double.infinity,
              height: cardTop + 52.r,
            ),
          ),
        ),

        //  White card (45% screen height)
        Positioned(
          top: cardTop,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(48.r),
                topRight: Radius.circular(48.r),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(28.w, 32.h, 28.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //  Heading
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                      height: 1.0,
                      letterSpacing: 0,
                    ),
                  ),

                  SizedBox(height: 31.h),

                  // Description
                  SizedBox(
                    width: 310.w,
                    child: Text(
                      data.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryText,
                        height: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                  ),

                  SizedBox(height: 35.h),

                  // Dot indicators
                  _DotIndicators(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    activeColor: AppColors.primaryText,
                  ),

                  SizedBox(height: 45.h),

                  //  Join the movement! button
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 236.w,
                      height: 60.h,
                      child: ElevatedButton(
                        onPressed: onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: backgroundColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(117.r),
                          ),
                        ),
                        child: Text(
                          'Join the movement!',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 38.h),

                  //  Login link
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () => context.goNamed('login'),
                      child: Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryText,
                          height: 1.0,
                          letterSpacing: 0,
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.solid,
                          decorationColor: AppColors.primaryText,
                          decorationThickness: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DotIndicators extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color activeColor;

  const _DotIndicators({
    required this.currentPage,
    required this.totalPages,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: isActive ? 19.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: AppColors.primaryText,
            borderRadius: BorderRadius.circular(5.r),
          ),
        );
      }),
    );
  }
}
