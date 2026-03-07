import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/router/page_transitions.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../app/main_shell.dart';
import 'otp_screen.dart';
import 'onboarding_name_screen.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authSubscription = AuthService.onAuthStateChange.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn && mounted) {
        // Utilisateur connecté via OAuth
        await _handleOAuthSuccess();
      }
    });
  }

  Future<void> _handleOAuthSuccess() async {
    // Enregistrer le token FCM après connexion OAuth réussie
    await PushNotificationService().registerAfterLogin();
    
    final profile = await AuthService.getCurrentProfile();
    final isNewUser = profile == null;
    
    if (!mounted) return;
    
    if (isNewUser) {
      // Nouvel utilisateur -> Onboarding
      final user = AuthService.currentUser;
      
      // Extraire nom et prénom des métadonnées OAuth
      final userMetadata = user?.userMetadata;
      String? firstName;
      String? lastName;
      
      if (userMetadata != null) {
        // Google fournit: given_name, family_name, full_name
        // Microsoft fournit: name, given_name, family_name
        firstName = userMetadata['given_name'] as String? 
            ?? userMetadata['first_name'] as String?;
        lastName = userMetadata['family_name'] as String? 
            ?? userMetadata['last_name'] as String?;
        
        // Si seulement full_name est disponible, essayer de le diviser
        if ((firstName == null || lastName == null) && userMetadata['full_name'] != null) {
          final fullName = userMetadata['full_name'] as String;
          final parts = fullName.split(' ');
          if (parts.isNotEmpty) {
            firstName ??= parts.first;
            if (parts.length > 1) {
              lastName ??= parts.sublist(1).join(' ');
            }
          }
        }
        
        // Microsoft peut aussi fournir 'name'
        if ((firstName == null || lastName == null) && userMetadata['name'] != null) {
          final name = userMetadata['name'] as String;
          final parts = name.split(' ');
          if (parts.isNotEmpty) {
            firstName ??= parts.first;
            if (parts.length > 1) {
              lastName ??= parts.sublist(1).join(' ');
            }
          }
        }
      }
      
      Navigator.of(context).pushAndRemoveUntil(
        AppPageRoute(
          page: OnboardingNameScreen(
            email: user?.email ?? '',
            initialFirstName: firstName,
            initialLastName: lastName,
          ),
          transitionType: PageTransitionType.phase,
          settings: const RouteSettings(name: '/auth/onboarding/name'),
        ),
        (route) => false,
      );
    } else {
      // Utilisateur existant -> Home
      Navigator.of(context).pushAndRemoveUntil(
        AppPageRoute(
          page: const MainShell(),
          transitionType: PageTransitionType.phase,
          settings: const RouteSettings(name: '/main'),
        ),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final email = _emailController.text.trim();
    // Regex pour valider un format email correct
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _onSubmit() async {
    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    
    // Envoyer le code OTP via Supabase
    final result = await AuthService.sendOtp(email);
    
    if (mounted) {
      setState(() => _isLoading = false);
      
      if (result['success'] == true) {
        // Navigate to OTP screen with slide transition
        context.navigateSlide(
          OtpScreen(
            email: email,
            isLogin: true,
          ),
          routeName: '/auth/otp',
        );
      } else {
        // Afficher l'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur lors de l\'envoi du code'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable main content
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppSpacing.vGapXl,

                    // Logo
                    Image.asset(
                      'assets/images/logo.png',
                      height: 40,
                      errorBuilder: (_, __, ___) => const AppLogo(
                        size: AppLogoSize.medium,
                      ),
                    ),

                    AppSpacing.vGapXxl,

                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.brandOlive,
                        borderRadius: AppRadius.borderRadiusLg,
                      ),
                      child: const Icon(
                        Icons.person_outlined,
                        size: 40,
                        color: AppColors.white,
                      ),
                    ),

                    AppSpacing.vGapLg,

                    // Title
                    Text(
                      'Connexion',
                      style: AppTypography.titleLarge,
                      textAlign: TextAlign.center,
                    ),

                    AppSpacing.vGapXs,

                    // Subtitle
                    Text(
                      'Connectez-vous pour accéder à votre espace',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    AppSpacing.vGapXl,

                    // Email field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: AppTypography.inputLabel,
                        ),
                        AppSpacing.vGapXs,
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() {}),
                          style: AppTypography.inputText,
                          decoration: InputDecoration(
                            hintText: 'votre@email.com',
                            hintStyle: AppTypography.inputHint,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 16, right: 12),
                              child: Icon(
                                Icons.email_outlined,
                                size: 22,
                                color: AppColors.iconSecondary,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            filled: true,
                            fillColor: AppColors.inputBackground,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.inputBorderRadius,
                              borderSide: BorderSide(color: AppColors.inputBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.inputBorderRadius,
                              borderSide: BorderSide(color: AppColors.inputBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.inputBorderRadius,
                              borderSide: BorderSide(
                                color: AppColors.inputBorderFocus,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.vGapXl,

                    // Submit button
                    AppButton(
                      label: 'Envoyer le code',
                      onPressed: _isFormValid ? _onSubmit : null,
                      variant: AppButtonVariant.primary,
                      size: AppButtonSize.large,
                      isFullWidth: true,
                      isLoading: _isLoading,
                      isDisabled: !_isFormValid,
                    ),

                    AppSpacing.vGapXl,

                    // Security trust indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Connexion sécurisée par code à usage unique',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Terms pinned at the bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'En continuant, vous acceptez nos ',
                    ),
                    TextSpan(
                      text: 'conditions générales d\'utilisation',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.brandPrimary,
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(
                      text: ' et notre ',
                    ),
                    TextSpan(
                      text: 'politique de confidentialité',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.brandPrimary,
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(
                      text: '.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

