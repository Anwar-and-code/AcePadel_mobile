import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/router/page_transitions.dart';
import '../models/reclamation.dart';
import '../services/reclamation_service.dart';
import 'create_reclamation_screen.dart';
import 'reclamation_detail_screen.dart';

/// Écran principal des réclamations
class ReclamationScreen extends StatefulWidget {
  const ReclamationScreen({super.key});

  @override
  State<ReclamationScreen> createState() => _ReclamationScreenState();
}

class _ReclamationScreenState extends State<ReclamationScreen> {
  @override
  void initState() {
    super.initState();
    ReclamationService.instance.loadReclamations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header simple
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingHorizontal,
                AppSpacing.lg,
                AppSpacing.screenPaddingHorizontal,
                AppSpacing.md,
              ),
              child: Text(
                'Réclamations',
                style: AppTypography.headlineMedium,
              ),
            ),

            // Content
            Expanded(
              child: ListenableBuilder(
                listenable: ReclamationService.instance,
                builder: (context, _) {
                  final service = ReclamationService.instance;

                  if (service.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (service.reclamations.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildReclamationsList(service.reclamations);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreate(),
        backgroundColor: AppColors.brandPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () => ReclamationService.instance.loadReclamations(),
      color: AppColors.brandPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 56,
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                  ),
                  AppSpacing.vGapLg,
                  Text(
                    'Aucune réclamation',
                    style: AppTypography.titleMedium,
                  ),
                  AppSpacing.vGapXs,
                  Text(
                    'Appuyez sur + pour signaler un problème',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReclamationsList(List<Reclamation> reclamations) {
    return RefreshIndicator(
      onRefresh: () => ReclamationService.instance.loadReclamations(),
      color: AppColors.brandPrimary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPaddingHorizontal,
          0,
          AppSpacing.screenPaddingHorizontal,
          100,
        ),
        itemCount: reclamations.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: AppColors.borderDefault.withValues(alpha: 0.5),
        ),
        itemBuilder: (context, index) {
          final reclamation = reclamations[index];
          return _ReclamationTile(
            reclamation: reclamation,
            onTap: () => _navigateToDetail(reclamation),
          );
        },
      ),
    );
  }

  void _navigateToCreate() {
    context.navigateSlide(
      const CreateReclamationScreen(),
      routeName: '/reclamation/create',
    );
  }

  void _navigateToDetail(Reclamation reclamation) {
    context.navigateSlide(
      ReclamationDetailScreen(reclamation: reclamation),
      routeName: '/reclamation/detail',
    );
  }
}

/// Ligne simple pour une réclamation — inspiré iOS/Material list tile
class _ReclamationTile extends StatelessWidget {
  final Reclamation reclamation;
  final VoidCallback onTap;

  const _ReclamationTile({
    required this.reclamation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(reclamation.status.colorValue);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Status indicator dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reclamation.subject,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(reclamation.createdAt),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                reclamation.status.label,
                style: AppTypography.labelSmall.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} jours';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}
