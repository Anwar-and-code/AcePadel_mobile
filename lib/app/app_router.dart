import 'package:flutter/material.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/auth/screens/email_screen.dart';
import '../features/auth/screens/register_screen.dart';
import 'main_shell.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String authEmail = '/auth/email';
  static const String authRegister = '/auth/register';
  static const String main = '/main';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      case onboarding:
        return _buildRoute(const OnboardingScreen(), settings);
      case authEmail:
        return _buildRoute(const EmailScreen(), settings);
      case authRegister:
        return _buildRoute(const RegisterScreen(), settings);
      case main:
        return _buildRoute(const MainShell(), settings);
      default:
        return _buildRoute(const SplashScreen(), settings);
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
