import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/router/page_transitions.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/services/points_service.dart';
import '../../../core/widgets/points_badge.dart';
import '../widgets/home_banner_carousel.dart';
import '../widgets/home_action_cards.dart';
import '../widgets/home_reservations_list.dart';
import '../../profile/screens/profile_screen.dart';
import '../../product_tour/product_tour.dart';

/// Home screen with product tour integration
/// 
/// Accepts GlobalKeys from MainShell for product tour showcase targets.
class HomeScreen extends StatefulWidget {
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  DateTime? _lastRefresh;
  static const _refreshThreshold = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshIfNeeded();
    }
  }

  void _loadData() {
    _lastRefresh = DateTime.now();
    UserProfileService.instance.loadProfile();
    PointsService.instance.loadPoints();
  }

  void _refreshIfNeeded() {
    if (_lastRefresh == null) {
      _loadData();
      return;
    }
    
    final timeSinceLastRefresh = DateTime.now().difference(_lastRefresh!);
    if (timeSinceLastRefresh >= _refreshThreshold) {
      _loadData();
    }
  }

  Future<void> _onRefresh() async {
    _lastRefresh = DateTime.now();
    await UserProfileService.instance.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.brandPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                    TextButton.icon(
                      onPressed: () => _showCallDialog(context),
                      icon: Icon(Icons.phone, color: AppColors.brandPrimary, size: 20),
                      label: Text(
                        'Contacter',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // User greeting with profile tour target
              Padding(
                padding: AppSpacing.screenPaddingHorizontalOnly,
                child: _wrapWithShowcase(
                  key: widget.tourProfileKey,
                  step: TourSteps.profile,
                  stepIndex: 4,
                  child: ListenableBuilder(
                    listenable: UserProfileService.instance,
                    builder: (context, _) {
                      final profile = UserProfileService.instance.profile;
                      return AppUserHeader(
                        name: profile?.displayName ?? 'Utilisateur',
                        greeting: 'Hello,',
                        avatarUrl: profile?.avatarUrl,
                        initials: profile?.initials ?? 'U',
                        onAvatarTap: () {
                          context.navigateSlide(
                            const ProfileScreen(),
                            routeName: '/profile',
                          );
                        },
                        trailing: const PointsBadge(),
                      );
                    },
                  ),
                ),
              ),

              AppSpacing.vGapMd,

              // Banner Carousel with tour target
              _wrapWithShowcase(
                key: widget.tourBannerKey,
                step: TourSteps.banner,
                stepIndex: 2,
                child: const HomeBannerCarousel(),
              ),

              AppSpacing.vGapMd,

              // Réservation en cours (priorité)
              const Padding(
                padding: AppSpacing.screenPaddingHorizontalOnly,
                child: HomeActiveReservation(),
              ),

              AppSpacing.vGapMd,

              // Let's Padel Section with tour target
              Padding(
                padding: AppSpacing.screenPaddingHorizontalOnly,
                child: _wrapWithShowcase(
                  key: widget.tourActionCardsKey,
                  step: TourSteps.actionCards,
                  stepIndex: 3,
                  child: const HomeActionCards(),
                ),
              ),

              AppSpacing.vGapLg,
            ],
          ),
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

  void _showCallDialog(BuildContext context) {
    const phoneNumber = '+2250799998888';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppSpacing.vGapLg,
            Text(
              'Contacter PadelHouse',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vGapSm,
            Text(
              '+225 07 99 99 88 88',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.vGapXl,
            // Bouton Appeler
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    launchUrl(Uri.parse('tel:$phoneNumber'));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.brandPrimary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.phone, color: AppColors.brandPrimary, size: 22),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Appeler sur la ligne directe',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AppSpacing.vGapMd,
            // Bouton WhatsApp
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    launchUrl(Uri.parse('https://wa.me/2250799998888'));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF25D366).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF25D366),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.call, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WhatsApp',
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF25D366),
                                ),
                              ),
                              Text(
                                'Réponse rapide',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AppSpacing.vGapLg,
          ],
        ),
      ),
    );
  }
}
