import 'package:flutter/material.dart';
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
                  Image.network(
                    event.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.neutral200),
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
                  // Title & Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBadge(
                        label: event.category,
                        variant: AppBadgeVariant.secondary,
                      ),
                      // Status or Price could go here
                    ],
                  ),
                  AppSpacing.vGapMd,
                  Text(
                    event.title,
                    style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary),
                  ),
                  AppSpacing.vGapSm,
                  
                  // Date, Time, Location
                  _buildInfoRow(AppIcons.calendar, event.date),
                  AppSpacing.vGapXs,
                  _buildInfoRow(AppIcons.clock, event.time),
                  AppSpacing.vGapXs,
                  _buildInfoRow(AppIcons.location, 'PadelHouse Club'), // Mobile app usually has location

                  AppSpacing.vGapLg,
                  
                  // Description
                  Text(
                    'À propos',
                    style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
                  ),
                  AppSpacing.vGapSm,
                  Text(
                    event.description, // Enhance with more dummy text if needed
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  
                  AppSpacing.vGapLg,

                  // Participants Check
                  Text(
                    'Participants (${event.participants}/${event.maxParticipants})',
                    style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
                  ),
                  AppSpacing.vGapSm,
                  LinearProgressIndicator(
                    value: event.participants / event.maxParticipants,
                    backgroundColor: AppColors.neutral200,
                    valueColor: AlwaysStoppedAnimation(AppColors.brandSecondary),
                    minHeight: 8,
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                  AppSpacing.vGapSm,
                  // Dummy avatars or list (simplified for now)
                   Row(
                    children: List.generate(
                      4, // Show first 4
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.neutral200,
                          child: Icon(AppIcons.profile, size: 16, color: AppColors.textSecondary),
                        ),
                      ),
                    )..add(
                      Text(
                        '+ ${event.participants - 4 > 0 ? event.participants - 4 : 0}',
                        style: AppTypography.caption,
                      ),
                    ),
                  ),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          border: Border(top: BorderSide(color: AppColors.neutral200)),
        ),
        child: SafeArea(
          child: AppButton(
            label: "S'inscrire à l'événement",
            onPressed: () => _showRegistrationDialog(context),
            variant: AppButtonVariant.primary,
            size: AppButtonSize.large,
            isFullWidth: true,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.brandPrimary),
        AppSpacing.hGapSm,
        Text(
          text,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  void _showRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDefault,
        title: Text('Confirmation', style: AppTypography.titleMedium),
        content: Text(
          'Voulez-vous confirmer votre inscription à ${event.title} ?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          AppButton(
            label: 'Confirmer',
            onPressed: () {
              Navigator.pop(context); // Close dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Inscription confirmée !'),
                  backgroundColor: AppColors.brandPrimary,
                ),
              );
            },
            variant: AppButtonVariant.primary,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }
}
