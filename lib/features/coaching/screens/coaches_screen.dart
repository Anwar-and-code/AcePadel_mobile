import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/router/page_transitions.dart';
import '../models/coach.dart';
import '../services/coaching_service.dart';
import 'coach_detail_screen.dart';

class CoachesScreen extends StatefulWidget {
  const CoachesScreen({super.key});

  @override
  State<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends State<CoachesScreen> {
  List<Coach> _coaches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCoaches();
  }

  Future<void> _loadCoaches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final coaches = await CoachingService.getCoaches();
      setState(() {
        _coaches = coaches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nos Coaches',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brandPrimary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            AppSpacing.vGapMd,
            Text(
              'Erreur de chargement',
              style: AppTypography.titleSmall,
            ),
            AppSpacing.vGapSm,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                _error!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            AppSpacing.vGapLg,
            TextButton.icon(
              onPressed: _loadCoaches,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_coaches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_tennis,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            AppSpacing.vGapMd,
            Text(
              'Aucun coach disponible',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.vGapSm,
            Text(
              'Revenez plus tard',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCoaches,
      color: AppColors.brandPrimary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _coaches.length,
        itemBuilder: (context, index) {
          final coach = _coaches[index];
          return _CoachCard(
            coach: coach,
            onTap: () {
              context.navigateSlide(
                CoachDetailScreen(coach: coach),
                routeName: '/coach-detail',
              );
            },
          );
        },
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final Coach coach;
  final VoidCallback onTap;

  const _CoachCard({
    required this.coach,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coach.fullName,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (coach.bio != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          coach.bio!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.brandPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'À partir de ${coach.formatPrice(coach.price1hTrio)}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.brandPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.brandPrimary.withValues(alpha: 0.1),
      ),
      child: coach.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: coach.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.brandPrimary,
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    coach.initials,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.brandPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                coach.initials,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.brandPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
