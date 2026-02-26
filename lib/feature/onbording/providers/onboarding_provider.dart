import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:software_lab_task/feature/onbording/models/onboarding_model.dart';
import 'package:software_lab_task/core/constant/colors.dart';
import 'package:software_lab_task/core/constant/assets.dart';

final onboardingDataProvider = Provider<List<OnboardingModel>>((ref) {
  return [
    OnboardingModel(
      title: 'Quality',
      description:
          'Sell your farm fresh products directly to consumers, cutting out the middleman and reducing emissions of the global supply chain.',
      assetPath: AppAssets.onboarding1Svg,
      backgroundColor: 'green',
    ),
    OnboardingModel(
      title: 'Convenient',
      description:
          'Our team of delivery drivers will make sure your orders are picked up on time and promptly delivered to your customers.',
      assetPath: AppAssets.onboarding2Svg,
      backgroundColor: 'coral',
    ),
    OnboardingModel(
      title: 'Local',
      description:
          'We love the earth and know you do too! Join us in reducing our local carbon footprint one order at a time.',
      assetPath: AppAssets.onboarding3Svg,
      backgroundColor: 'yellow',
    ),
  ];
});

final currentPageProvider = StateProvider<int>((ref) => 0);

final pageControllerProvider = Provider<PageController>((ref) {
  return PageController();
});

Color getBackgroundColor(String colorType) {
  switch (colorType) {
    case 'green':
      return AppColors.tertiary;
    case 'coral':
      return AppColors.primary;
    case 'yellow':
      return AppColors.secondary;
    default:
      return AppColors.tertiary;
  }
}
