import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/push_notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _logoSlideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Background transition: Gold -> White (Phase 1)
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _backgroundColorAnimation = ColorTween(
      begin: AppColors.brandPrimary,
      end: AppColors.white,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    
    // Logo animation (Phase 2)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _logoScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );
    
    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    // Phase 1: Hold gold background briefly
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Phase 2: Transition background to white (off-white)
    _backgroundController.forward();
    
    // Phase 3: After background starts, animate logo
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    // Phase 4: Check if user is already logged in
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      await _checkAuthAndNavigate();
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user != null) {
      // User is logged in, check if profile exists
      final profile = await AuthService.getCurrentProfile();
      
      if (mounted) {
        if (profile != null) {
          // Réenregistrer le token FCM au retour
          await PushNotificationService().registerAfterLogin();
          // Profile exists -> go to main
          Navigator.of(context).pushReplacementNamed('/main');
        } else {
          // No profile -> go to auth to complete profile
          Navigator.of(context).pushReplacementNamed('/auth/email');
        }
      }
    } else {
      // Not logged in -> go to onboarding
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_backgroundController, _logoController]),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _backgroundColorAnimation.value,
          body: Center(
            child: FadeTransition(
              opacity: _logoFadeAnimation,
              child: SlideTransition(
                position: _logoSlideAnimation,
                child: ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: const AppLogoImage(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Logo widget for the splash screen — renders the brand logo directly
class AppLogoImage extends StatelessWidget {
  final double? width;
  final double? height;
  
  const AppLogoImage({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return const AppLogo(
      size: AppLogoSize.xlarge,
      variant: AppLogoVariant.stacked,
    );
  }
}
