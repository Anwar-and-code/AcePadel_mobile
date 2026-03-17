import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.arrowBack, color: AppColors.iconPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'À propos',
          style: AppTypography.titleLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppSpacing.vGapXl,

            // App Logo & Version
            const AppLogo(
              size: AppLogoSize.xlarge,
              variant: AppLogoVariant.monogram,
            ),
            AppSpacing.vGapLg,
            Text(
              'AcePadel',
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vGapXs,
            Text(
              'Version 1.0.0',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.vGapXxs,
            AppBadge(
              label: 'Build 2026.01.04',
              variant: AppBadgeVariant.info,
            ),

            AppSpacing.vGapXxl,

            // About Section
            Padding(
              padding: AppSpacing.screenPaddingHorizontalOnly,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: AppRadius.cardBorderRadius,
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notre mission',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.vGapMd,
                    Text(
                      'AcePadel est la première application de réservation de courts de padel en Côte d\'Ivoire. Notre mission est de démocratiser l\'accès au padel et de créer une communauté passionnée autour de ce sport en pleine expansion.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    AppSpacing.vGapMd,
                    Text(
                      'Nous offrons une expérience de réservation simple et intuitive, permettant à tous les joueurs de trouver et réserver des courts en quelques clics.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            AppSpacing.vGapLg,

            // Features Section
            Padding(
              padding: AppSpacing.screenPaddingHorizontalOnly,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: AppRadius.cardBorderRadius,
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fonctionnalités',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.vGapMd,
                    _FeatureItem(
                      icon: Icons.calendar_today,
                      title: 'Réservation facile',
                      description: 'Réservez votre court en quelques secondes',
                    ),
                    _FeatureItem(
                      icon: Icons.people,
                      title: 'Communauté active',
                      description: 'Trouvez des partenaires de jeu',
                    ),
                    _FeatureItem(
                      icon: Icons.emoji_events,
                      title: 'Tournois',
                      description: 'Participez à des compétitions locales',
                    ),
                    _FeatureItem(
                      icon: Icons.notifications,
                      title: 'Rappels',
                      description: 'Ne manquez jamais un match',
                    ),
                  ],
                ),
              ),
            ),

            AppSpacing.vGapLg,

            // Team Section
            Padding(
              padding: AppSpacing.screenPaddingHorizontalOnly,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: AppRadius.cardBorderRadius,
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'L\'équipe',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.vGapMd,
                    Row(
                      children: [
                        _TeamMemberAvatar(
                          name: 'Fondateur',
                          role: 'CEO',
                          imageUrl: AppImages.teamMember1,
                        ),
                        AppSpacing.hGapMd,
                        _TeamMemberAvatar(
                          name: 'Tech Lead',
                          role: 'CTO',
                          imageUrl: AppImages.teamMember2,
                        ),
                        AppSpacing.hGapMd,
                        _TeamMemberAvatar(
                          name: 'Designer',
                          role: 'UX/UI',
                          imageUrl: AppImages.teamMember3,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            AppSpacing.vGapLg,

            // Social Links
            Padding(
              padding: AppSpacing.screenPaddingHorizontalOnly,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suivez-nous',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppSpacing.vGapMd,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _SocialButton(
                        icon: Icons.language,
                        label: 'Website',
                        onTap: () => _showLinkMessage(context, 'www.acepadel.ci'),
                      ),
                      AppSpacing.hGapMd,
                      _SocialButton(
                        icon: Icons.facebook,
                        label: 'Facebook',
                        onTap: () => _showLinkMessage(context, 'facebook.com/acepadel'),
                      ),
                      AppSpacing.hGapMd,
                      _SocialButton(
                        icon: Icons.camera_alt,
                        label: 'Instagram',
                        onTap: () => _showLinkMessage(context, '@acepadel_ci'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            AppSpacing.vGapXl,

            // Credits
            Padding(
              padding: AppSpacing.screenPaddingHorizontalOnly,
              child: Column(
                children: [
                  Divider(color: AppColors.borderDefault),
                  AppSpacing.vGapMd,
                  Text(
                    '© 2026 AcePadel. Tous droits réservés.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  AppSpacing.vGapXs,
                  Text(
                    'Fait avec ❤️ en Côte d\'Ivoire',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.vGapXxl,
          ],
        ),
      ),
    );
  }

  void _showLinkMessage(BuildContext context, String link) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(link),
        backgroundColor: AppColors.brandPrimary,
        action: SnackBarAction(
          label: 'Copier',
          textColor: AppColors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(icon, color: AppColors.brandPrimary, size: 20),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMemberAvatar extends StatelessWidget {
  const _TeamMemberAvatar({
    required this.name,
    required this.role,
    required this.imageUrl,
  });

  final String name;
  final String role;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(imageUrl),
        ),
        AppSpacing.vGapXs,
        Text(
          name,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          role,
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.borderRadiusMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderRadiusMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: AppColors.brandPrimary),
                AppSpacing.hGapXs,
                Text(
                  label,
                  style: AppTypography.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
