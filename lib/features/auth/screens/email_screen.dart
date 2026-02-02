import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/router/page_transitions.dart';
import '../../../core/services/auth_service.dart';
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

  void _signInWithGoogle() async {
    setState(() => _isLoading = true);
    
    final result = await AuthService.signInWithGoogle();
    
    if (mounted) {
      setState(() => _isLoading = false);
      
      if (result['success'] == true) {
        // Google Sign-In natif retourne directement le résultat
        await _handleOAuthSuccess();
      } else if (result['error'] != 'CANCELLED') {
        // Afficher l'erreur seulement si ce n'est pas une annulation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur de connexion Google'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _signInWithMicrosoft() async {
    setState(() => _isLoading = true);
    
    final result = await AuthService.signInWithMicrosoft();
    
    if (mounted) {
      setState(() => _isLoading = false);
      
      if (result['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur de connexion Microsoft'),
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

              AppSpacing.vGapLg,

              // Divider with "OU"
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.inputBorder,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OU',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.inputBorder,
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              AppSpacing.vGapLg,

              // Google sign-in button
              // SizedBox(
              //   height: 56,
              //   width: double.infinity,
              //   child: OutlinedButton(
              //     onPressed: _signInWithGoogle,
              //     style: OutlinedButton.styleFrom(
              //       backgroundColor: const Color(0xFFFFFFFF),
              //       side: BorderSide(color: AppColors.inputBorder),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: AppRadius.inputBorderRadius,
              //       ),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Image.asset(
              //           'assets/images/google_icon.png',
              //           width: 20,
              //           height: 20,
              //           errorBuilder: (_, __, ___) => const Icon(
              //             Icons.g_mobiledata,
              //             size: 24,
              //             color: AppColors.textPrimary,
              //           ),
              //         ),
              //         const SizedBox(width: 12),
              //         Text(
              //           'Continuer avec Google',
              //           style: AppTypography.buttonMedium.copyWith(
              //             color: AppColors.textPrimary,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              //
              // AppSpacing.vGapMd,

              // Microsoft sign-in button
              SizedBox(
                height: 56,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _signInWithMicrosoft,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFFFF),
                    side: BorderSide(color: AppColors.inputBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.inputBorderRadius,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/microsoft_icon.png',
                        width: 20,
                        height: 20,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.window,
                          size: 24,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continuer avec Microsoft',
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacing.vGapXxl,
              AppSpacing.vGapXxl,

              // Terms and conditions at the bottom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(
                        text: 'En continuant, vous acceptez nos ',
                      ),
                      TextSpan(
                        text: 'conditions générales d\'utilisations',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.brandPrimary,
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

              AppSpacing.vGapXl,
            ],
          ),
        ),
      ),
    );
  }
}

