import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final hasEmail = _emailController.text.contains('@');
    final hasPassword = _passwordController.text.length >= 6;
    if (_isLogin) {
      return hasEmail && hasPassword;
    }
    return hasEmail && hasPassword && _acceptedTerms;
  }

  void _onSubmit() async {
    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    // Simulate API call
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

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _acceptedTerms = false;
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
              ),

              AppSpacing.vGapMd,

              // Password field
              AppTextField(
                controller: _passwordController,
                label: 'Mot de passe',
                hint: '••••••••',
                prefixIcon: Icons.lock_outlined,
                obscureText: _obscurePassword,
                suffixIcon: _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                onSuffixTap: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                onChanged: (_) => setState(() {}),
              ),

              if (_isLogin) ...[
                AppSpacing.vGapSm,
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Forgot password flow
                    },
                    child: Text(
                      'Mot de passe oublié ?',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
              ],

              if (!_isLogin) ...[
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
                label: _isLogin ? 'Se connecter' : "S'inscrire",
                onPressed: _isFormValid ? _onSubmit : null,
                variant: AppButtonVariant.primary,
                size: AppButtonSize.large,
                isFullWidth: true,
                isLoading: _isLoading,
                isDisabled: !_isFormValid,
              ),

              AppSpacing.vGapLg,

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.borderDefault)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text(
                      'ou',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.borderDefault)),
                ],
              ),

              AppSpacing.vGapLg,

              // Social login buttons
              _SocialLoginButton(
                label: 'Continuer avec Google',
                icon: Icons.g_mobiledata,
                onTap: () {
                  // TODO: Google sign in
                },
              ),

              AppSpacing.vGapSm,

              _SocialLoginButton(
                label: 'Continuer avec Apple',
                icon: Icons.apple,
                onTap: () {
                  // TODO: Apple sign in
                },
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

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderDefault),
        borderRadius: AppRadius.buttonBorderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.buttonBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.buttonBorderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
                AppSpacing.hGapMd,
                Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textPrimary,
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
