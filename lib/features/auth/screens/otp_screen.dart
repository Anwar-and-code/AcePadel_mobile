import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/router/page_transitions.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../app/main_shell.dart';
import '../../../core/services/points_service.dart';
import 'register_screen.dart';
import 'onboarding_name_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final bool isLogin;
  
  const OtpScreen({
    super.key,
    required this.email,
    this.isLogin = true,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otpCode = '';
  int _resendTimer = 60;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
        return true;
      }
      return false;
    });
  }

  void _onKeyPressed(String key) {
    if (_otpCode.length < 6) {
      setState(() => _otpCode += key);
      
      // Auto-verify when complete
      if (_otpCode.length == 6) {
        _verifyCode();
      }
    }
  }

  void _onBackspace() {
    if (_otpCode.isNotEmpty) {
      setState(() => _otpCode = _otpCode.substring(0, _otpCode.length - 1));
    }
  }

  void _verifyCode() async {
    setState(() => _isVerifying = true);
    
    // Vérifier le code OTP via Supabase
    final result = await AuthService.verifyOtp(widget.email, _otpCode);
    
    if (mounted) {
      setState(() => _isVerifying = false);
      
      if (result['success'] == true) {
        // Enregistrer le token FCM après connexion réussie
        await PushNotificationService().registerAfterLogin();
        
        final isNewUser = result['is_new_user'] == true;
        
        if (isNewUser) {
          // Nouvel utilisateur -> Onboarding
          Navigator.of(context).pushAndRemoveUntil(
            AppPageRoute(
              page: OnboardingNameScreen(email: widget.email),
              transitionType: PageTransitionType.phase,
              settings: const RouteSettings(name: '/auth/onboarding/name'),
            ),
            (route) => false,
          );
        } else {
          // Utilisateur existant avec profil -> Home
          // Charger les points
          await PointsService.instance.loadPoints();
          
          Navigator.of(context).pushAndRemoveUntil(
            AppPageRoute(
              page: const MainShell(),
              transitionType: PageTransitionType.phase,
              settings: const RouteSettings(name: '/main'),
            ),
            (route) => false,
          );
        }
      } else {
        // Erreur - afficher le message
        setState(() => _otpCode = ''); // Reset le code
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Code incorrect !'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  void _resendCode() async {
    if (_resendTimer == 0) {
      setState(() {
        _resendTimer = 60;
        _otpCode = '';
      });
      _startResendTimer();
      
      // Renvoyer le code OTP
      final result = await AuthService.sendOtp(widget.email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['success'] == true 
                ? 'Code renvoyé à ${widget.email}' 
                : result['message'] ?? 'Erreur lors de l\'envoi'),
            backgroundColor: result['success'] == true 
                ? AppColors.success 
                : AppColors.error,
            duration: const Duration(seconds: 2),
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
            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs, top: AppSpacing.xs),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
              ),
            ),
            // Top section with logo, title, and OTP boxes
            Expanded(
              flex: 3,
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  children: [
                    // Logo
                    const AppLogo(
                      size: AppLogoSize.large,
                    ),
                    
                    AppSpacing.vGapXxl,
                    
                    // Title
                    Text(
                      'Authentification',
                      style: AppTypography.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    
                    AppSpacing.vGapSm,
                    
                    // Email address
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          const TextSpan(text: 'Code envoyé à '),
                          TextSpan(
                            text: widget.email,
                            style: TextStyle(
                              color: AppColors.brandSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    AppSpacing.vGapXxl,
                    
                    // OTP Display Boxes (6 digits for Supabase)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        final hasValue = index < _otpCode.length;
                        final value = hasValue ? _otpCode[index] : '';
                        
                        return Container(
                          width: 48,
                          height: 56,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: hasValue 
                                ? AppColors.brandSecondary.withValues(alpha: 0.1)
                                : AppColors.brandOlive.withValues(alpha: 0.08),
                            borderRadius: AppRadius.borderRadiusMd,
                            border: Border.all(
                              color: hasValue 
                                  ? AppColors.brandSecondary
                                  : AppColors.brandOlive.withValues(alpha: 0.3),
                              width: hasValue ? 2 : 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              value,
                              style: AppTypography.headlineLarge.copyWith(
                                color: AppColors.brandSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    
                    AppSpacing.vGapXl,
                    
                    // Resend options
                    Text(
                      "Vous n'avez pas reçu de code ?",
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppSpacing.vGapXs,
                    GestureDetector(
                      onTap: _resendTimer == 0 ? _resendCode : null,
                      child: Text(
                        _resendTimer > 0
                            ? 'Renvoyer (${_resendTimer}s)'
                            : 'Renvoyer',
                        style: AppTypography.bodyMedium.copyWith(
                          color: _resendTimer > 0
                              ? AppColors.textTertiary
                              : AppColors.brandSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AppSpacing.vGapLg,
                    
                    // Loading indicator
                    if (_isVerifying)
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.brandSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Numeric keypad
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    _buildKeypadRow(['1', '2', '3']),
                    _buildKeypadRow(['4', '5', '6']),
                    _buildKeypadRow(['7', '8', '9']),
                    _buildKeypadRow(['', '0', 'back']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((key) => _buildKey(key)).toList(),
      ),
    );
  }

  Widget _buildKey(String key) {
    if (key.isEmpty) {
      return const SizedBox(width: 90, height: 60);
    }

    final isBackspace = key == 'back';

    return Material(
      color: isBackspace ? Colors.transparent : AppColors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: isBackspace ? 0 : 1,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: isBackspace ? _onBackspace : () => _onKeyPressed(key),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 90,
          height: 60,
          alignment: Alignment.center,
          child: isBackspace
              ? Icon(
                  Icons.backspace_outlined,
                  color: AppColors.textPrimary,
                  size: 26,
                )
              : Text(
                  key,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}
