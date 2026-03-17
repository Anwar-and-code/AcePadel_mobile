import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design_system/design_system.dart';
import '../models/event.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        slivers: [
          // 1. Hero Image & AppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.backgroundPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (event.coverImageUrl != null)
                    Image.network(
                      event.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.neutral200,
                        child: Icon(AppIcons.events, size: 48, color: AppColors.neutral400),
                      ),
                    )
                  else
                    Container(
                      color: AppColors.neutral200,
                      child: Icon(AppIcons.events, size: 48, color: AppColors.neutral400),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          AppColors.backgroundPrimary,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundPrimary.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(AppIcons.arrowBack, color: AppColors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 2. Content
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.screenPaddingHorizontalOnly,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppBadge(
                        label: event.categoryLabel,
                        variant: AppBadgeVariant.secondary,
                      ),
                      if (event.isFree)
                        AppBadge(
                          label: 'Gratuit',
                          variant: AppBadgeVariant.success,
                        ),
                      if (!event.isFree && event.priceInfo != null)
                        AppBadge(
                          label: event.priceInfo!,
                          variant: AppBadgeVariant.info,
                        ),
                      if (event.isOngoing)
                        AppBadge(
                          label: 'En cours',
                          variant: AppBadgeVariant.success,
                        ),
                      if (!event.isUpcoming && !event.isOngoing)
                        AppBadge(
                          label: 'Terminé',
                          variant: AppBadgeVariant.info,
                        ),
                    ],
                  ),
                  AppSpacing.vGapMd,

                  // Title
                  Text(
                    event.title,
                    style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary),
                  ),
                  if (event.subtitle != null) ...[
                    AppSpacing.vGapXs,
                    Text(
                      event.subtitle!,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                  AppSpacing.vGapMd,

                  // Info card
                  Container(
                    padding: AppSpacing.cardPaddingAll,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: AppRadius.cardBorderRadius,
                      boxShadow: AppShadows.cardShadow,
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(AppIcons.calendar, event.formattedDate),
                        AppSpacing.vGapSm,
                        _buildInfoRow(AppIcons.clock, event.formattedTime),
                        AppSpacing.vGapSm,
                        _buildInfoRow(AppIcons.location, event.location),
                      ],
                    ),
                  ),

                  AppSpacing.vGapLg,

                  // Description
                  Text(
                    'À propos',
                    style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
                  ),
                  AppSpacing.vGapSm,
                  Text(
                    event.longDescription ?? event.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  // Tags
                  if (event.tags.isNotEmpty) ...[
                    AppSpacing.vGapLg,
                    Text(
                      'Tags',
                      style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
                    ),
                    AppSpacing.vGapSm,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: event.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary.withValues(alpha: 0.1),
                            borderRadius: AppRadius.borderRadiusFull,
                          ),
                          child: Text(
                            '#$tag',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.brandPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Info Ligne / Contact
                  if (event.contactPhone != null && event.contactPhone!.isNotEmpty) ...[
                    AppSpacing.vGapLg,
                    Text(
                      'Info & Contact',
                      style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
                    ),
                    AppSpacing.vGapSm,
                    Container(
                      padding: AppSpacing.cardPaddingAll,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: AppRadius.cardBorderRadius,
                        boxShadow: AppShadows.cardShadow,
                      ),
                      child: InkWell(
                        onTap: () => _showContactDialog(context),
                        borderRadius: AppRadius.cardBorderRadius,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.brandPrimary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.phone, color: AppColors.brandPrimary, size: 22),
                            ),
                            AppSpacing.hGapMd,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ligne directe',
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatPhone(event.contactPhone!),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Photo gallery
                  if (event.images.isNotEmpty) ...[
                    AppSpacing.vGapLg,
                    Text(
                      'Photos',
                      style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
                    ),
                    AppSpacing.vGapSm,
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: event.images.length,
                        separatorBuilder: (_, __) => AppSpacing.hGapMd,
                        itemBuilder: (context, index) {
                          final image = event.images[index];
                          return GestureDetector(
                            onTap: () => _showFullImage(context, image),
                            child: ClipRRect(
                              borderRadius: AppRadius.borderRadiusMd,
                              child: SizedBox(
                                width: 240,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      image.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: AppColors.neutral200,
                                        child: Icon(AppIcons.events, color: AppColors.neutral400),
                                      ),
                                    ),
                                    if (image.caption != null)
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.black.withValues(alpha: 0.7),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                          child: Text(
                                            image.caption!,
                                            style: AppTypography.caption.copyWith(
                                              color: AppColors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  AppSpacing.vGapXxl,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.brandPrimary),
        AppSpacing.hGapSm,
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  String _formatPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+225') && digits.length >= 13) {
      final local = digits.substring(4);
      return '+225 ${local.substring(0, 2)} ${local.substring(2, 4)} ${local.substring(4, 6)} ${local.substring(6, 8)} ${local.substring(8)}';
    }
    return raw;
  }

  String _rawPhone(String phone) => phone.replaceAll(RegExp(r'[^0-9+]'), '');

  void _showContactDialog(BuildContext context) {
    final phoneNumber = _rawPhone(event.contactPhone!);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppSpacing.vGapLg,
            Text(
              'Contacter AcePadel',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vGapSm,
            Text(
              _formatPhone(event.contactPhone!),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.vGapXl,
            // Bouton Appeler
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    launchUrl(Uri.parse('tel:$phoneNumber'));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.brandPrimary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.phone, color: AppColors.brandPrimary, size: 22),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Appeler sur la ligne directe',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AppSpacing.vGapMd,
            // Bouton WhatsApp
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    final waNumber = phoneNumber.startsWith('+') ? phoneNumber.substring(1) : phoneNumber;
                    launchUrl(Uri.parse('https://wa.me/$waNumber'));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF25D366).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF25D366),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.call, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WhatsApp',
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF25D366),
                                ),
                              ),
                              Text(
                                'Réponse rapide',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AppSpacing.vGapLg,
          ],
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, EventImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: AppRadius.borderRadiusLg,
              child: Image.network(
                image.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  height: 300,
                  color: AppColors.neutral200,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(AppIcons.close, color: AppColors.white, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (image.caption != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    image.caption!,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
