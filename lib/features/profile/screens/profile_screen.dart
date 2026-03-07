import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/router/page_transitions.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../features/auth/screens/email_screen.dart';
import '../../../core/services/points_service.dart';
import 'personal_info_screen.dart';
import 'legal_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Recharger le profil à l'ouverture
    UserProfileService.instance.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with back button and settings
              Container(
                height: 56,
                padding: AppSpacing.screenPaddingHorizontalOnly,
                child: Row(
                  children: [
                    // Back Button (Leading)
                    AppIconButton(
                      icon: AppIcons.arrowBack,
                      onPressed: () => Navigator.of(context).pop(),
                      variant: AppButtonVariant.ghost,
                    ),
                    
                    // Title (Centered with Expanded)
                    Expanded(
                      child: Text(
                        'Profil',
                        style: AppTypography.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Placeholder for symmetry
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              AppSpacing.vGapLg,

              // Profile info
              const _ProfileHeader(),

              AppSpacing.vGapXl,

              // Menu options
              const _ProfileMenuSection(),

              AppSpacing.vGapXl,

              // Logout button
              Padding(
                padding: AppSpacing.screenPaddingHorizontalOnly,
                child: AppButton(
                  label: 'Se déconnecter',
                  icon: AppIcons.logout,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        backgroundColor: AppColors.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          'Se déconnecter',
                          style: AppTypography.titleMedium,
                        ),
                        content: Text(
                          'Êtes-vous sûr de vouloir vous déconnecter ?',
                          style: AppTypography.bodyMedium,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(
                              'Annuler',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                              // Désactiver le token FCM avant déconnexion
                              await PushNotificationService().unregisterOnLogout();
                              // Sign out from Supabase
                              await AuthService.signOut();
                              // Navigate to login screen
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  AppPageRoute(
                                    page: const EmailScreen(),
                                    transitionType: PageTransitionType.phase,
                                    settings: const RouteSettings(name: '/auth/email'),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            child: Text(
                              'Déconnexion',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  variant: AppButtonVariant.outline,
                  isFullWidth: true,
                ),
              ),

              AppSpacing.vGapXxl,
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatefulWidget {
  const _ProfileHeader();

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    
    // Afficher le choix entre caméra et galerie
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Changer la photo', style: AppTypography.titleMedium),
            AppSpacing.vGapLg,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PhotoOption(
                  icon: Icons.camera_alt,
                  label: 'Caméra',
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                _PhotoOption(
                  icon: Icons.photo_library,
                  label: 'Galerie',
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                if (UserProfileService.instance.profile?.hasAvatar == true)
                  _PhotoOption(
                    icon: Icons.delete,
                    label: 'Supprimer',
                    color: AppColors.error,
                    onTap: () => Navigator.pop(context, null),
                  ),
              ],
            ),
            AppSpacing.vGapLg,
          ],
        ),
      ),
    );

    if (source == null && UserProfileService.instance.profile?.hasAvatar == true) {
      // Supprimer la photo
      setState(() => _isUploading = true);
      await UserProfileService.instance.removeAvatar();
      setState(() => _isUploading = false);
      return;
    }

    if (source == null) return;

    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    final file = File(pickedFile.path);
    final result = await UserProfileService.instance.uploadAvatar(file);

    setState(() => _isUploading = false);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Photo mise à jour !'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erreur lors de l\'upload'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserProfileService.instance,
      builder: (context, _) {
        final profile = UserProfileService.instance.profile;
        final isLoading = UserProfileService.instance.isLoading;

        return Column(
          children: [
            // Avatar
            Stack(
              children: [
                GestureDetector(
                  onTap: _isUploading ? null : _pickAndUploadImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.brandPrimary,
                        width: 3,
                      ),
                      color: profile?.hasAvatar != true 
                          ? AppColors.brandPrimary.withValues(alpha: 0.15)
                          : null,
                      image: profile?.hasAvatar == true
                          ? DecorationImage(
                              image: NetworkImage(profile!.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: profile?.hasAvatar != true
                        ? Center(
                            child: Text(
                              profile?.initials ?? 'U',
                              style: AppTypography.headlineLarge.copyWith(
                                color: AppColors.brandPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                if (_isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.black.withValues(alpha: 0.5),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _isUploading ? null : _pickAndUploadImage,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        AppIcons.camera,
                        size: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.vGapMd,

            // Name and info
            if (isLoading)
              const CircularProgressIndicator()
            else ...[
              Text(
                profile?.fullName ?? 'Utilisateur',
                style: AppTypography.headlineSmall,
              ),
              AppSpacing.vGapXxs,
              Text(
                profile?.email ?? '',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (profile?.phone != null && profile!.phone!.isNotEmpty) ...[
                AppSpacing.vGapXs,
                Text(
                  profile.phone!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _PhotoOption extends StatelessWidget {
  const _PhotoOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: (color ?? AppColors.brandPrimary).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color ?? AppColors.brandPrimary),
          ),
          AppSpacing.vGapXs,
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.cardBorderRadius,
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            AppSpacing.vGapXs,
            Text(
              value,
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            AppSpacing.vGapXxs,
            Text(
              label,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuSection extends StatelessWidget {
  const _ProfileMenuSection();

  Future<void> _launchArmasoft() async {
    final uri = Uri.parse('https://www.armasoft.ci');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mon compte Section
        _buildSectionHeader('Mon compte'),
        AppSpacing.vGapSm,
        _buildMenuCard(context, [
          _MenuTile(
            icon: Icons.person_outline,
            title: 'Informations personnelles',
            subtitle: 'Gérer vos données personnelles',
            onTap: () {
              context.navigateSlide(
                const PersonalInfoScreen(),
                routeName: '/profile/personal-info',
              );
            },
          ),
          _MenuTile(
            icon: Icons.history,
            title: 'Historique des réservations',
            subtitle: 'Voir toutes vos réservations',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(AppIcons.calendar, color: AppColors.white),
                      AppSpacing.hGapSm,
                      Expanded(child: Text('Rendez-vous dans l\'onglet "Réservations"')),
                    ],
                  ),
                  backgroundColor: AppColors.brandPrimary,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ]),

        AppSpacing.vGapXl,

        // Légal Section
        _buildSectionHeader('Légal'),
        AppSpacing.vGapSm,
        _buildMenuCard(context, [
          _MenuTile(
            icon: Icons.description_outlined,
            title: 'Conditions d\'utilisation',
            subtitle: 'Lire nos conditions générales',
            onTap: () {
              context.navigateSlide(
                const TermsOfServiceScreen(),
                routeName: '/legal/terms',
              );
            },
          ),
          _MenuTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Politique de confidentialité',
            subtitle: 'Comment nous protégeons vos données',
            onTap: () {
              context.navigateSlide(
                const PrivacyPolicyScreen(),
                routeName: '/legal/privacy',
              );
            },
          ),
        ]),

        AppSpacing.vGapXl,

        // Développé par ArmaSOFT
        _buildSectionHeader('Développé par'),
        AppSpacing.vGapSm,
        _buildMenuCard(context, [
          _MenuTile(
            icon: Icons.code,
            title: 'ArmaSOFT',
            subtitle: 'www.armasoft.ci',
            onTap: _launchArmasoft,
          ),
        ]),

        AppSpacing.vGapXl,

        // Zone de danger - Supprimer mon compte
        _buildSectionHeader('Zone de danger'),
        AppSpacing.vGapSm,
        _buildDangerCard(context, [
          _MenuTile(
            icon: Icons.delete_outline,
            title: 'Supprimer mon compte',
            subtitle: 'Supprimer définitivement votre compte',
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ]),
      ],
    );
  }

  Widget _buildDangerCard(BuildContext context, List<Widget> children) {
    return Container(
      margin: AppSpacing.screenPaddingHorizontalOnly,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.cardBorderRadius,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: AppSpacing.md + 40 + AppSpacing.md,
                color: AppColors.borderDefault,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: AppSpacing.screenPaddingHorizontalOnly,
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, List<Widget> children) {
    return Container(
      margin: AppSpacing.screenPaddingHorizontalOnly,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.cardBorderRadius,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: AppSpacing.md + 40 + AppSpacing.md,
                color: AppColors.borderDefault,
              ),
          ],
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundPrimary,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDefault,
                borderRadius: AppRadius.borderRadiusFull,
              ),
            ),
            AppSpacing.vGapLg,

            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 32,
              ),
            ),
            AppSpacing.vGapLg,

            // Title
            Text(
              'Supprimer mon compte',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vGapMd,

            // Description
            Text(
              'Cette action est irréversible. Toutes vos données personnelles, réservations et historique seront supprimées définitivement.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapXl,

            // Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Annuler',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Un email de confirmation vous a été envoyé'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusMd,
                      ),
                    ),
                    child: Text(
                      'Supprimer',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.brandPrimary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: titleColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                AppIcons.chevronRight,
                color: iconColor ?? AppColors.iconTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
