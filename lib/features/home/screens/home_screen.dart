import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/router/page_transitions.dart';
import '../widgets/home_banner_carousel.dart';
import '../widgets/home_action_cards.dart';
import '../widgets/home_reservations_list.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/screens/notifications_screen.dart';
import '../../gamification/widgets/user_progress_ring.dart';
import '../../product_tour/product_tour.dart';

/// Home screen with product tour integration
/// 
/// Accepts GlobalKeys from MainShell for product tour showcase targets.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.tourBannerKey,
    this.tourActionCardsKey,
    this.tourProfileKey,
  });

  /// GlobalKey for banner carousel showcase
  final GlobalKey? tourBannerKey;
  
  /// GlobalKey for action cards showcase
  final GlobalKey? tourActionCardsKey;
  
  /// GlobalKey for profile/progress ring showcase
  final GlobalKey? tourProfileKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo and notification
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPaddingHorizontal,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppLogo(
                      size: AppLogoSize.medium,
                    ),
                    AppNotificationBadge(
                      showBadge: true,
                      count: 3,
                      child: AppIconButton(
                        icon: AppIcons.notification,
                        onPressed: () {
                          context.navigateSlide(
                            const NotificationsScreen(),
                            routeName: '/notifications',
                          );
                        },
                        variant: AppButtonVariant.ghost,
                      ),
                    ),
                  ],
                ),
              ),

              // User greeting with profile tour target
              Padding(
                padding: AppSpacing.screenPaddingHorizontalOnly,
                child: _wrapWithShowcase(
                  key: tourProfileKey,
                  step: TourSteps.profile,
                  stepIndex: 4,
                  child: AppUserHeader(
                    name: 'Alexandre',
                    greeting: 'Hello,',
                    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
                    onAvatarTap: () {
                      context.navigateSlide(
                        const ProfileScreen(),
                        routeName: '/profile',
                      );
                    },
                    trailing: const UserProgressRing(size: 46, showXp: true),
                  ),
                ),
              ),

              AppSpacing.vGapLg,

              // Banner Carousel with tour target
              _wrapWithShowcase(
                key: tourBannerKey,
                step: TourSteps.banner,
                stepIndex: 2,
                child: const HomeBannerCarousel(),
              ),

              AppSpacing.vGapXl,

              // Réservation en cours (priorité)
              const Padding(
                padding: AppSpacing.screenPaddingHorizontalOnly,
                child: HomeActiveReservation(),
              ),

              AppSpacing.vGapXl,

              // Let's Padel Section with tour target
              Padding(
                padding: AppSpacing.screenPaddingHorizontalOnly,
                child: _wrapWithShowcase(
                  key: tourActionCardsKey,
                  step: TourSteps.actionCards,
                  stepIndex: 3,
                  child: const HomeActionCards(),
                ),
              ),

              AppSpacing.vGapXl,

              // Historique des réservations
              const Padding(
                padding: AppSpacing.screenPaddingHorizontalOnly,
                child: HomeReservationsHistory(),
              ),

              AppSpacing.vGapXxl,
            ],
          ),
        ),
      ),
    );
  }

  /// Wraps a widget with Showcase if a key is provided
  Widget _wrapWithShowcase({
    required GlobalKey? key,
    required TourStep step,
    required int stepIndex,
    required Widget child,
  }) {
    if (key == null) return child;

    return Showcase(
      key: key,
      title: step.title,
      description: step.description,
      tooltipBackgroundColor: AppColors.cardBackground,
      textColor: AppColors.textPrimary,
      descTextStyle: AppTypography.bodySmall.copyWith(
        color: AppColors.textSecondary,
      ),
      titleTextStyle: AppTypography.titleSmall.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      tooltipPadding: const EdgeInsets.all(AppSpacing.lg),
      targetBorderRadius: AppRadius.borderRadiusMd,
      targetPadding: const EdgeInsets.all(AppSpacing.sm),
      child: child,
    );
  }
}
