import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLogin = true;
  bool _acceptedTerms = false;
  bool _isLoading = false;
  bool _otpSent = false;
  int _resendCountdown = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCountdown--);
      return _resendCountdown > 0;
    });
  }

  bool get _isFormValid {
    final hasEmail = _emailController.text.contains('@');
    if (!_otpSent) {
      // Before OTP is sent, check email and terms (for registration)
      if (_isLogin) {
        return hasEmail;
      }
      return hasEmail && _acceptedTerms;
    } else {
      // After OTP is sent, check if OTP code is complete (6 digits)
      return _otpController.text.length == 6;
    }
  }

  void _onSubmit() async {
    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    if (!_otpSent) {
      // Send OTP to email
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpSent = true;
        });
        _startResendCountdown();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Code envoyé à ${_emailController.text}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      // Verify OTP code
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() => _isLoading = false);
        
        if (_isLogin) {
          // Login -> Go to main app
          Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
        } else {
          // Register -> Go to complete profile
          Navigator.of(context).pushNamed('/auth/register');
        }
      }
    }
  }

  void _resendOtp() async {
    if (_resendCountdown > 0) return;
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _isLoading = false);
      _startResendCountdown();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code renvoyé avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _acceptedTerms = false;
      _otpSent = false;
      _otpController.clear();
    });
  }

  void _changeEmail() {
    setState(() {
      _otpSent = false;
      _otpController.clear();
    });
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
                  color: AppColors.brandPrimary,
                ),
              ),

              AppSpacing.vGapXxl,

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: AppRadius.borderRadiusLg,
                ),
                child: Icon(
                  _isLogin ? Icons.login_outlined : Icons.person_add_outlined,
                  size: 40,
                  color: AppColors.brandPrimary,
                ),
              ),

              AppSpacing.vGapLg,

              // Title
              Text(
                _isLogin ? 'Connexion' : 'Créer un compte',
                style: AppTypography.titleLarge,
                textAlign: TextAlign.center,
              ),

              AppSpacing.vGapXs,

              // Subtitle
              Text(
                _isLogin
                    ? 'Connectez-vous pour accéder à votre espace'
                    : 'Inscrivez-vous pour réserver vos terrains',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              AppSpacing.vGapXxl,

              // Email field
              AppTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'votre@email.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
                enabled: !_otpSent,
              ),

              if (_otpSent) ...[
                AppSpacing.vGapSm,
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _changeEmail,
                    child: Text(
                      'Changer d\'email',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
              ],

              AppSpacing.vGapMd,

              // OTP field (only shown after email is submitted)
              if (_otpSent) ...[
                AppTextField(
                  controller: _otpController,
                  label: 'Code de vérification',
                  hint: '000000',
                  prefixIcon: Icons.lock_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  maxLength: 6,
                ),
                AppSpacing.vGapSm,
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resendCountdown > 0 ? null : _resendOtp,
                    child: Text(
                      _resendCountdown > 0
                          ? 'Renvoyer le code ($_resendCountdown s)'
                          : 'Renvoyer le code',
                      style: AppTypography.bodySmall.copyWith(
                        color: _resendCountdown > 0
                            ? AppColors.textDisabled
                            : AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
              ],

              if (_isLogin && !_otpSent) ...[
                const SizedBox.shrink(),
              ],

              if (!_isLogin && !_otpSent) ...[
                AppSpacing.vGapMd,

                // Terms checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _acceptedTerms,
                        onChanged: (value) {
                          setState(() => _acceptedTerms = value ?? false);
                        },
                        activeColor: AppColors.brandPrimary,
                      ),
                    ),
                    AppSpacing.hGapSm,
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _acceptedTerms = !_acceptedTerms);
                        },
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(
                                text: "J'accepte les ",
                              ),
                              TextSpan(
                                text: "conditions générales d'utilisation",
                                style: TextStyle(
                                  color: AppColors.brandPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(text: " et la "),
                              TextSpan(
                                text: "politique de confidentialité",
                                style: TextStyle(
                                  color: AppColors.brandPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              AppSpacing.vGapXl,

              // Submit button
              AppButton(
                label: _otpSent
                    ? 'Vérifier le code'
                    : (_isLogin ? 'Envoyer le code' : "S'inscrire"),
                onPressed: _isFormValid ? _onSubmit : null,
                variant: AppButtonVariant.primary,
                size: AppButtonSize.large,
                isFullWidth: true,
                isLoading: _isLoading,
                isDisabled: !_isFormValid,
              ),

              AppSpacing.vGapXl,

              // Toggle login/register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin
                        ? "Pas encore de compte ? "
                        : "Déjà un compte ? ",
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleMode,
                    child: Text(
                      _isLogin ? "S'inscrire" : "Se connecter",
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              AppSpacing.vGapLg,
            ],
          ),
        ),
      ),
    );
  }
}

