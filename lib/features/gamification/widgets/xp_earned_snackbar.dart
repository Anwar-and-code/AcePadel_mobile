import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

class XpEarnedSnackbar extends StatelessWidget {
  final int xpAmount;
  final String message;

  const XpEarnedSnackbar({
    super.key, 
    required this.xpAmount,
    this.message = 'XP Gagnés',
  });

  static void show(BuildContext context, int xp) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: XpEarnedSnackbar(xpAmount: xp),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandSecondary.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandSecondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star,
              color: AppColors.brandSecondary,
              size: 20,
            ),
          ),
          AppSpacing.hGapMd,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+$xpAmount XP',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.brandSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                message,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
