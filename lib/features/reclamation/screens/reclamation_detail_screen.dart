import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../models/reclamation.dart';

/// Écran de détail d'une réclamation
class ReclamationDetailScreen extends StatelessWidget {
  final Reclamation reclamation;

  const ReclamationDetailScreen({
    super.key,
    required this.reclamation,
  });

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
          'Détail réclamation',
          style: AppTypography.titleLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            _buildStatusCard(),

            AppSpacing.vGapXl,

            // Informations
            _buildSection(
              title: 'Sujet',
              child: Text(
                reclamation.subject,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            AppSpacing.vGapLg,

            _buildSection(
              title: 'Catégorie',
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  reclamation.category.label,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.brandPrimary,
                  ),
                ),
              ),
            ),

            AppSpacing.vGapLg,

            _buildSection(
              title: 'Description',
              child: Text(
                reclamation.description,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // Photos
            if (reclamation.photoUrls.isNotEmpty) ...[
              AppSpacing.vGapLg,
              _buildSection(
                title: 'Photos jointes',
                child: _buildPhotosGrid(),
              ),
            ],

            // Réponse admin
            if (reclamation.adminResponse != null) ...[
              AppSpacing.vGapLg,
              _buildAdminResponse(),
            ],

            AppSpacing.vGapLg,

            // Date
            _buildSection(
              title: 'Date de création',
              child: Text(
                _formatFullDate(reclamation.createdAt),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            if (reclamation.resolvedAt != null) ...[
              AppSpacing.vGapMd,
              _buildSection(
                title: 'Date de résolution',
                child: Text(
                  _formatFullDate(reclamation.resolvedAt!),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Color(reclamation.status.colorValue).withValues(alpha: 0.1),
        borderRadius: AppRadius.cardBorderRadius,
        border: Border.all(
          color: Color(reclamation.status.colorValue).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(reclamation.status.colorValue).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(),
              color: Color(reclamation.status.colorValue),
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statut',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  reclamation.status.label,
                  style: AppTypography.titleSmall.copyWith(
                    color: Color(reclamation.status.colorValue),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (reclamation.status) {
      case ReclamationStatus.pending:
        return Icons.hourglass_empty;
      case ReclamationStatus.inProgress:
        return Icons.autorenew;
      case ReclamationStatus.resolved:
        return Icons.check_circle;
      case ReclamationStatus.rejected:
        return Icons.cancel;
    }
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.vGapXs,
        child,
      ],
    );
  }

  Widget _buildPhotosGrid() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: reclamation.photoUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showFullImage(context, reclamation.photoUrls[index]),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.network(
                  reclamation.photoUrls[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        color: AppColors.brandPrimary,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.neutral200,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(url),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminResponse() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: AppRadius.cardBorderRadius,
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.support_agent,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Réponse de l\'équipe',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppSpacing.vGapSm,
          Text(
            reclamation.adminResponse!,
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
