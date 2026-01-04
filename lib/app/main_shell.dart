import 'package:flutter/material.dart';
import '../core/design_system/design_system.dart';
import '../features/home/screens/home_screen.dart';
import '../features/reservation/screens/reservation_screen.dart';
import '../features/events/screens/events_screen.dart';
import '../features/social/screens/social_screen.dart';
import '../features/profile/screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ReservationScreen(),
    EventsScreen(),
    SocialScreen(),
    ProfileScreen(),
  ];

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
      label: 'Social',
      icon: AppIcons.group,
      activeIcon: AppIcons.groupFilled,
    ),
    AppNavItem(
      label: 'Profil',
      icon: AppIcons.profile,
      activeIcon: AppIcons.profileFilled,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _navItems,
      ),
    );
  }
}
