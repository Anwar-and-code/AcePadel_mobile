import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

class HomeActionCards extends StatelessWidget {
  const HomeActionCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: "Let's Padel"),
        AppSpacing.vGapMd,
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'Réserver un terrain',
                icon: AppIcons.sportsTennis,
                imageUrl: 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=400&q=80',
                onTap: () {
                  // Navigate to reservation tab (index 1 in bottom nav)
                  DefaultTabController.of(context).animateTo(1);
                },
              ),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: _ActionCard(
                title: 'Voir les replays',
                icon: AppIcons.playCircle,
                imageUrl: 'https://images.unsplash.com/photo-1526232761682-d26e03ac148e?w=400&q=80',
                onTap: () {
                  // Show coming soon message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fonctionnalité bientôt disponible'),
                      backgroundColor: AppColors.brandPrimary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.imageUrl,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final String imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.brandPrimary.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.neutral300,
                            AppColors.neutral400,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: 48,
                          color: AppColors.neutral600,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.neutral100,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),

                // Modern multi-layer gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.transparent,
                        AppColors.black.withValues(alpha: 0.3),
                        AppColors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

                // Content with glassmorphism effect
                Positioned(
                  left: AppSpacing.md,
                  bottom: AppSpacing.md,
                  right: AppSpacing.md,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: AppColors.white,
                          size: 22,
                        ),
                      ),
                      AppSpacing.hGapSm,
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            shadows: [
                              Shadow(
                                color: AppColors.black.withValues(alpha: 0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
