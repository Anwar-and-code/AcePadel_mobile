import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import '../../design_system.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.lottieUrl,
    this.assetPath,
    this.actionLabel,
    this.onAction,
  }) : assert(lottieUrl != null || assetPath != null, 'Must provide either lottieUrl or assetPath');

  final String title;
  final String message;
  final String? lottieUrl;
  final String? assetPath;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation in GlassContainer
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.glassSurface,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SizedBox(
                height: 200,
                width: 200,
                child: lottieUrl != null
                    ? Lottie.network(
                        lottieUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                           return Icon(
                              AppIcons.info, 
                              size: 64, 
                              color: AppColors.neutral400
                           );
                        },
                      )
                    : Lottie.asset(
                        assetPath!,
                        fit: BoxFit.contain,
                      ),
              ),
            )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .fadeIn(duration: 600.ms),

            const Gap(32),

            // Text Content
            Text(
              title,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

            const Gap(12),
            
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

            if (actionLabel != null && onAction != null) ...[
              const Gap(32),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: Text(actionLabel!),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            ],
          ],
        ),
      ),
    );
  }
}
