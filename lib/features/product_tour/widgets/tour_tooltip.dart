import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../data/tour_steps.dart';

/// Custom tooltip widget for the product tour
/// 
/// Styled to match AcePadel design system with
/// brand colors, typography, and consistent spacing.
class TourTooltip extends StatelessWidget {
  const TourTooltip({
    super.key,
    required this.step,
    required this.currentStep,
    required this.totalSteps,
    this.onNext,
    this.onSkip,
    this.isLastStep = false,
  });

  final TourStep step;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final bool isLastStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.brandPrimary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Step counter
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Text(
                  'Étape $currentStep/$totalSteps',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Skip button
              if (!isLastStep)
                GestureDetector(
                  onTap: onSkip,
                  child: Text(
                    'Passer',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
          
          AppSpacing.vGapMd,
          
          // Icon and title
          Row(
            children: [
              if (step.icon != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Icon(
                    step.icon,
                    size: 20,
                    color: AppColors.brandPrimary,
                  ),
                ),
                AppSpacing.hGapSm,
              ],
              Expanded(
                child: Text(
                  step.title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          AppSpacing.vGapSm,
          
          // Description
          Text(
            step.description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          
          AppSpacing.vGapMd,
          
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalSteps,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == currentStep - 1 ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: index == currentStep - 1
                      ? AppColors.brandPrimary
                      : AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          
          AppSpacing.vGapMd,
          
          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                elevation: 0,
              ),
              child: Text(
                isLastStep ? 'C\'est parti!' : 'Suivant',
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
