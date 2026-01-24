import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/router/page_transitions.dart';
import '../models/reclamation.dart';
import '../services/reclamation_service.dart';
import 'create_reclamation_screen.dart';
import 'reclamation_detail_screen.dart';

/// Filtre de période
enum DateFilter {
  all('Tout', null),
  today('Aujourd\'hui', 0),
  week('Cette semaine', 7),
  month('Ce mois', 30);

  final String label;
  final int? days;
  const DateFilter(this.label, this.days);
}

/// Écran principal des réclamations
class ReclamationScreen extends StatefulWidget {
  const ReclamationScreen({super.key});

  @override
  State<ReclamationScreen> createState() => _ReclamationScreenState();
}

class _ReclamationScreenState extends State<ReclamationScreen> {
  ReclamationStatus? _selectedStatus;
  DateFilter _selectedDateFilter = DateFilter.all;

  @override
  void initState() {
    super.initState();
    ReclamationService.instance.loadReclamations();
  }

  List<Reclamation> _filterReclamations(List<Reclamation> reclamations) {
    var filtered = reclamations;

    // Filtre par statut
    if (_selectedStatus != null) {
      filtered = filtered.where((r) => r.status == _selectedStatus).toList();
    }

    // Filtre par date
    if (_selectedDateFilter.days != null) {
      final now = DateTime.now();
      final cutoff = now.subtract(Duration(days: _selectedDateFilter.days!));
      filtered = filtered.where((r) => r.createdAt.isAfter(cutoff)).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Réclamations',
                    style: AppTypography.headlineMedium,
                  ),
                  AppSpacing.vGapXxs,
                  Text(
                    'Signalez un problème ou une suggestion',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Filtres
            _buildFilters(),

            AppSpacing.vGapMd,

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

                  final filtered = _filterReclamations(service.reclamations);
                  
                  if (filtered.isEmpty) {
                    return _buildNoResultsState();
                  }

                  return _buildReclamationsList(filtered);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(),
        backgroundColor: AppColors.brandPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Nouvelle réclamation',
          style: AppTypography.labelMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        // Filtre par statut
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              _FilterChip(
                label: 'Tous',
                isSelected: _selectedStatus == null,
                onTap: () => setState(() => _selectedStatus = null),
              ),
              const SizedBox(width: 8),
              ...ReclamationStatus.values.map((status) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: status.label,
                  isSelected: _selectedStatus == status,
                  color: Color(status.colorValue),
                  onTap: () => setState(() => _selectedStatus = status),
                ),
              )),
            ],
          ),
        ),
        AppSpacing.vGapSm,
        // Filtre par date
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: DateFilter.values.map((filter) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _DateFilterChip(
                label: filter.label,
                isSelected: _selectedDateFilter == filter,
                onTap: () => setState(() => _selectedDateFilter = filter),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () => ReclamationService.instance.loadReclamations(),
      color: AppColors.brandPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.support_agent_outlined,
                      size: 64,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                  AppSpacing.vGapXl,
                  Text(
                    'Aucune réclamation',
                    style: AppTypography.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vGapSm,
                  Text(
                    'Vous n\'avez pas encore soumis de réclamation.\nSi vous rencontrez un problème, n\'hésitez pas à nous le signaler.',
                    style: AppTypography.bodyMedium.copyWith(
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

  Widget _buildNoResultsState() {
    return RefreshIndicator(
      onRefresh: () => ReclamationService.instance.loadReclamations(),
      color: AppColors.brandPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.filter_list_off,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  AppSpacing.vGapMd,
                  Text(
                    'Aucun résultat',
                    style: AppTypography.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vGapXs,
                  Text(
                    'Aucune réclamation ne correspond aux filtres sélectionnés.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vGapLg,
                  TextButton(
                    onPressed: () => setState(() {
                      _selectedStatus = null;
                      _selectedDateFilter = DateFilter.all;
                    }),
                    child: Text(
                      'Réinitialiser les filtres',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.brandPrimary,
                      ),
                    ),
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
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 100),
        itemCount: reclamations.length,
        separatorBuilder: (_, __) => AppSpacing.vGapMd,
        itemBuilder: (context, index) {
          final reclamation = reclamations[index];
          return _ReclamationCard(
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

/// Chip de filtre par statut
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.brandPrimary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.borderDefault,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Chip de filtre par date
class _DateFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.brandPrimary.withValues(alpha: 0.1) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.borderDefault,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.brandPrimary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? AppColors.brandPrimary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte d'une réclamation
class _ReclamationCard extends StatelessWidget {
  final Reclamation reclamation;
  final VoidCallback onTap;

  const _ReclamationCard({
    required this.reclamation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardBorderRadius,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: AppRadius.cardBorderRadius,
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec statut
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reclamation.subject,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusBadge(status: reclamation.status),
                ],
              ),
              AppSpacing.vGapSm,
              // Description
              Text(
                reclamation.description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.vGapMd,
              // Footer
              Row(
                children: [
                  // Catégorie
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      reclamation.category.label,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Photos indicator
                  if (reclamation.photoUrls.isNotEmpty) ...[
                    Icon(
                      Icons.photo_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${reclamation.photoUrls.length}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  // Date
                  Text(
                    _formatDate(reclamation.createdAt),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
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

/// Badge de statut
class _StatusBadge extends StatelessWidget {
  final ReclamationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: Color(status.colorValue).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: AppTypography.labelSmall.copyWith(
          color: Color(status.colorValue),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
