import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../services/points_service.dart';

/// Badge affichant les points de l'utilisateur
class PointsBadge extends StatelessWidget {
  const PointsBadge({super.key, this.size = 46});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PointsService.instance,
      builder: (context, _) {
        final points = PointsService.instance.points;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.brandPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.brandPrimary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                color: AppColors.brandSecondary,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '$points',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.brandPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
