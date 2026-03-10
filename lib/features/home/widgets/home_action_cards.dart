import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../../app/app_router.dart';
import '../../../core/design_system/design_system.dart';

/// Notification to trigger tab switch in MainShell
class MainShellTabNotification extends Notification {
  final int tabIndex;
  final int? subTabIndex;
  const MainShellTabNotification({required this.tabIndex, this.subTabIndex});
}

class HomeActionCards extends StatelessWidget {
  const HomeActionCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: "À vos raquettes !"),
        const Gap(16),
        SizedBox(
          height: 280, // Fixed height for the bento grid
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LARGE CARD (Left)
              Expanded(
                flex: 5,
                child: _BentoCard(
                  title: 'Réserver\nun court',
                  subtitle: 'Jouez maintenant',
                  icon: AppIcons.sportsTennis,
                  imageUrl: AppImages.homeReservation,
                  color: AppColors.brandPrimary,
                  isLarge: true,
                  onTap: () {
                    // Dispatch notification to MainShell to switch to Reservation tab (onglet Réserver)
                    MainShellTabNotification(tabIndex: 1, subTabIndex: 0).dispatch(context);
                  },
                ),
              ),
              const Gap(12),
              // RIGHT COLUMN
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    // TOP RIGHT CARD
                    Expanded(
                      child: _BentoCard(
                        title: 'Replays',
                        icon: AppIcons.playCircle,
                        imageUrl: AppImages.homeReplays,
                        color: AppColors.brandSecondary,
                        isDisabled: true,
                        comingSoonLabel: 'Bientôt',
                      ),
                    ),
                    const Gap(12),
                    // BOTTOM RIGHT CARD (New)
                    Expanded(
                      child: _BentoCard(
                        title: 'Coaching',
                        icon: AppIcons.coaching,
                        imageUrl: AppImages.homeCoaching,
                        color: AppColors.brandPrimary,
                        isDisabled: true,
                        comingSoonLabel: 'Bientôt',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]
      .animate(interval: 50.ms)
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
    );
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.imageUrl,
    required this.color,
    this.isLarge = false,
    this.onTap,
    this.isDisabled = false,
    this.comingSoonLabel,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String imageUrl;
  final Color color;
  final bool isLarge;
  final VoidCallback? onTap;
  final bool isDisabled;
  final String? comingSoonLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: AppColors.surfaceDefault,
          child: InkWell(
            onTap: isDisabled ? null : onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Background Image using NetworkImage
                ColorFiltered(
                  colorFilter: isDisabled
                      ? const ColorFilter.matrix(<double>[
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0,      0,      0,      1, 0,
                        ])
                      : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.neutral300),
                  ),
                ),

                // 2. Gradient Overlay (Glass/Dark)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDisabled
                          ? [
                              Colors.transparent,
                              AppColors.black.withValues(alpha: 0.4),
                              AppColors.black.withValues(alpha: 0.85),
                            ]
                          : [
                              Colors.transparent,
                              AppColors.black.withValues(alpha: 0.3),
                              AppColors.black.withValues(alpha: 0.8),
                            ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),

                // 3. Neon Glow Effect (subtle)
                if (isLarge && !isDisabled)
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonGlow,
                            blurRadius: 50,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),

                // 4. Coming soon badge
                if (isDisabled && comingSoonLabel != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        comingSoonLabel!,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),

                // 5. Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Icon (no wrapper)
                      Icon(
                        icon,
                        color: isDisabled
                            ? AppColors.white.withValues(alpha: 0.5)
                            : AppColors.white,
                        size: isLarge ? 32 : 26,
                      ),
                      const Gap(12),
                      
                      // Text Content
                      Text(
                        title,
                        style: isLarge 
                          ? AppTypography.headlineSmall.copyWith(
                              color: isDisabled
                                  ? AppColors.white.withValues(alpha: 0.5)
                                  : AppColors.white,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            )
                          : AppTypography.titleMedium.copyWith(
                              color: isDisabled
                                  ? AppColors.white.withValues(alpha: 0.5)
                                  : AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      
                      if (subtitle != null && isLarge) ...[
                        const Gap(4),
                        Text(
                          subtitle!,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDisabled
                                ? AppColors.neutral200.withValues(alpha: 0.5)
                                : AppColors.neutral200,
                          ),
                        ),
                      ],
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
