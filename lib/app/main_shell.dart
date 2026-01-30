import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../core/design_system/design_system.dart';
import '../core/services/product_tour_service.dart';
import '../core/services/user_profile_service.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/widgets/home_action_cards.dart';
import '../features/reservation/screens/reservation_screen_v2.dart';
import '../features/events/screens/events_screen.dart';
import '../features/reclamation/reclamation.dart';
import '../features/product_tour/product_tour.dart';

/// Main application shell with bottom navigation
/// 
/// Wraps content in ShowCaseWidget for product tour support
/// and triggers tour for first-time users.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _tourActive = false;

  // GlobalKeys for product tour showcase targets
  final GlobalKey _navBarKey = GlobalKey();
  final GlobalKey _bannerKey = GlobalKey();
  final GlobalKey _actionCardsKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _dateSelectorKey = GlobalKey();
  final GlobalKey _courtSelectorKey = GlobalKey();
  final GlobalKey _eventsNavKey = GlobalKey();
  final GlobalKey<ReservationScreenV2State> _reservationKey = GlobalKey<ReservationScreenV2State>();

  late final List<Widget> _screens;

  static const List<AppNavItem> _navItems = [
    AppNavItem(
      label: 'Accueil',
      icon: AppIcons.home,
      activeIcon: AppIcons.homeFilled,
    ),
    AppNavItem(
      label: 'Réservation',
      icon: AppIcons.reservation,
      activeIcon: AppIcons.reservationFilled,
    ),
    AppNavItem(
      label: 'Événements',
      icon: AppIcons.events,
      activeIcon: AppIcons.eventsFilled,
    ),
    AppNavItem(
      label: 'Réclamation',
      icon: AppIcons.support,
      activeIcon: AppIcons.supportFilled,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Create screens with tour keys passed down
    _screens = [
      HomeScreen(
        tourBannerKey: _bannerKey,
        tourActionCardsKey: _actionCardsKey,
        tourProfileKey: _profileKey,
      ),
      ReservationScreenV2(
        key: _reservationKey,
        tourDateSelectorKey: _dateSelectorKey,
        tourCourtSelectorKey: _courtSelectorKey,
      ),
      const EventsScreen(),
      const ReclamationScreen(),
    ];
  }

  void _handleTourStep(int? index) {
    if (index == null || !_tourActive) return;
    
    // Navigate to appropriate tab when tour reaches certain steps
    // Steps 5-6 are on Reservation tab (index 1)
    // Step 7 is Events tab (index 2)
    int targetTab = 0;
    if (index >= 4 && index <= 5) {
      targetTab = 1; // Reservation tab
    } else if (index == 6) {
      targetTab = 2; // Events tab
    }
    
    if (_currentIndex != targetTab) {
      setState(() => _currentIndex = targetTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<MainShellTabNotification>(
      onNotification: (notification) {
        setState(() => _currentIndex = notification.tabIndex);
        // Si un subTabIndex est spécifié et qu'on va sur l'onglet réservation
        if (notification.subTabIndex != null && notification.tabIndex == 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _reservationKey.currentState?.switchToTab(notification.subTabIndex!);
          });
        }
        return true; // Stop propagation
      },
      child: ShowCaseWidget(
        onStart: (index, key) => _handleTourStep(index),
      onComplete: (index, key) async {
        if (index == 6) {
          // Tour completed
          _tourActive = false;
          await ProductTourService.setTourCompleted(true);
        }
      },
      onFinish: () {
        _tourActive = false;
      },
      builder: (context) => _MainShellContent(
        currentIndex: _currentIndex,
        onTabChanged: (index) {
          setState(() => _currentIndex = index);
          // Recharger le profil quand on change d'onglet
          UserProfileService.instance.loadProfile();
          // Réinitialiser l'onglet Réservation sur "Réserver" quand on y navigue
          if (index == 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _reservationKey.currentState?.switchToTab(0);
            });
          }
        },
        screens: _screens,
        navItems: _navItems,
        navBarKey: _navBarKey,
        bannerKey: _bannerKey,
        actionCardsKey: _actionCardsKey,
        profileKey: _profileKey,
        dateSelectorKey: _dateSelectorKey,
        courtSelectorKey: _courtSelectorKey,
        eventsNavKey: _eventsNavKey,
        onTourStarted: () => _tourActive = true,
      ),
      ),
    );
  }
}

class _MainShellContent extends StatefulWidget {
  const _MainShellContent({
    required this.currentIndex,
    required this.onTabChanged,
    required this.screens,
    required this.navItems,
    required this.navBarKey,
    required this.bannerKey,
    required this.actionCardsKey,
    required this.profileKey,
    required this.dateSelectorKey,
    required this.courtSelectorKey,
    required this.eventsNavKey,
    required this.onTourStarted,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final List<Widget> screens;
  final List<AppNavItem> navItems;
  final GlobalKey navBarKey;
  final GlobalKey bannerKey;
  final GlobalKey actionCardsKey;
  final GlobalKey profileKey;
  final GlobalKey dateSelectorKey;
  final GlobalKey courtSelectorKey;
  final GlobalKey eventsNavKey;
  final VoidCallback onTourStarted;

  @override
  State<_MainShellContent> createState() => _MainShellContentState();
}

class _MainShellContentState extends State<_MainShellContent> {
  bool _tourInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_tourInitialized) {
      _tourInitialized = true;
      _initProductTour();
    }
  }

  Future<void> _initProductTour() async {
    // Product tour désactivé
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: widget.currentIndex,
          children: widget.screens,
        ),
        bottomNavigationBar: Showcase(
          key: widget.navBarKey,
          title: TourSteps.welcome.title,
          description: TourSteps.welcome.description,
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
          child: AppBottomNavBar(
            currentIndex: widget.currentIndex,
            onTap: widget.onTabChanged,
            items: widget.navItems,
          ),
        ),
    );
  }
}
