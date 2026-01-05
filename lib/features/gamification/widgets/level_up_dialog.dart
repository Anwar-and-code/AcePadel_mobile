import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/design_system/design_system.dart';

class LevelUpDialog extends StatelessWidget {
  final int newLevel;

  const LevelUpDialog({super.key, required this.newLevel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Content Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surfaceDefault,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.brandPrimary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandPrimary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 100), // Space for Lottie
                Text(
                  'Niveau Supérieur !',
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.vGapMd,
                Text(
                  'Félicitations ! Vous avez atteint le niveau $newLevel.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.vGapLg,
                AppButton(
                  label: 'Génial !',
                  onPressed: () => Navigator.of(context).pop(),
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.medium,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
          
          // Lottie Animation (Trophy/Confetti)
          Positioned(
            top: -50,
            height: 200,
            width: 200,
            child: Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_touohxv0.json', // Free Trophy Animation
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.emoji_events,
                size: 100,
                color: AppColors.brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
