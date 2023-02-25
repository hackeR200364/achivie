import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../styles.dart';

class CustomGlassIconButton extends StatelessWidget {
  const CustomGlassIconButton({
    super.key,
    this.tabController,
    required this.onPressed,
    required this.icon,
  });

  final PageController? tabController;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: 41,
      height: 41,
      borderRadius: 40,
      linearGradient: AppColors.customGlassButtonGradient,
      border: 2,
      blur: 4,
      borderGradient: AppColors.customGlassButtonBorderGradient,
      child: Center(
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
