import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _eventService = EventService.instance;

  @override
  void initState() {
    super.initState();
    _eventService.addListener(_onServiceChanged);
    if (_eventService.events.isEmpty) {
      _eventService.loadEvents();
    }
  }

  @override
  void dispose() {
    _eventService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _onRefresh() async {
    await _eventService.loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    final featured = _eventService.featuredEvent;
    final upcoming = _eventService.nonFeaturedUpcomingEvents;
    final past = _eventService.pastEvents;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Événements',
          style: AppTypography.titleLarge,
        ),
        centerTitle: true,
      ),
      body: _eventService.isLoading && _eventService.events.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _eventService.error != null && _eventService.events.isEmpty
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.brandPrimary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Featured event
                        if (featured != null) ...[
                          Padding(
                            padding: AppSpacing.screenPaddingHorizontalOnly,
                            child: _FeaturedEventCard(event: featured),
                          ),
                          AppSpacing.vGapXl,
                        ],

                        // Upcoming events
                        if (upcoming.isNotEmpty) ...[
                          Padding(
                            padding: AppSpacing.screenPaddingHorizontalOnly,
                            child: const AppSectionHeader(
                              title: 'Événements à venir',
                            ),
                          ),
                          AppSpacing.vGapMd,
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: AppSpacing.screenPaddingHorizontalOnly,
                            itemCount: upcoming.length,
                            separatorBuilder: (_, __) => AppSpacing.vGapMd,
                            itemBuilder: (context, index) {
                              return _EventCard(event: upcoming[index]);
                            },
                          ),
                          AppSpacing.vGapXl,
                        ],

                        // Past events
                        if (past.isNotEmpty) ...[
                          Padding(
                            padding: AppSpacing.screenPaddingHorizontalOnly,
                            child: const AppSectionHeader(
                              title: 'Événements passés',
                            ),
                          ),
                          AppSpacing.vGapMd,
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: AppSpacing.screenPaddingHorizontalOnly,
                            itemCount: past.length,
                            separatorBuilder: (_, __) => AppSpacing.vGapMd,
                            itemBuilder: (context, index) {
                              return _EventCard(
                                event: past[index],
                                isPast: true,
                              );
                            },
                          ),
                        ],

                        // Empty state
                        if (featured == null && upcoming.isEmpty && past.isEmpty)
                          _buildEmptyState(),

                        AppSpacing.vGapXxl,
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.events, size: 64, color: AppColors.neutral300),
            AppSpacing.vGapMd,
            Text(
              'Impossible de charger les événements',
              style: AppTypography.titleSmall,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapSm,
            AppButton(
              label: 'Réessayer',
              onPressed: () => _eventService.loadEvents(),
              variant: AppButtonVariant.primary,
              size: AppButtonSize.small,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.events, size: 64, color: AppColors.neutral300),
            AppSpacing.vGapMd,
            Text(
              'Aucun événement pour le moment',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapXs,
            Text(
              'Revenez bientôt pour découvrir nos prochains événements !',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedEventCard extends StatelessWidget {
  const _FeaturedEventCard({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardBorderRadius,
        boxShadow: AppShadows.shadowMd,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.cardBorderRadius,
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
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

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: AppSpacing.cardPaddingLargeAll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category + Price badges
                    Row(
                      children: [
                        AppBadge(
                          label: event.categoryLabel,
                          variant: AppBadgeVariant.secondary,
                        ),
                        if (!event.isFree && event.priceInfo != null) ...[
                          AppSpacing.hGapXs,
                          AppBadge(
                            label: event.priceInfo!,
                            variant: AppBadgeVariant.info,
                          ),
                        ],
                        if (event.isFree) ...[
                          AppSpacing.hGapXs,
                          AppBadge(
                            label: 'Gratuit',
                            variant: AppBadgeVariant.success,
                          ),
                        ],
                      ],
                    ),

                    const Spacer(),

                    // Title
                    Text(
                      event.title,
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (event.subtitle != null) ...[
                      AppSpacing.vGapXxs,
                      Text(
                        event.subtitle!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    AppSpacing.vGapSm,

                    // Date & Time
                    Row(
                      children: [
                        Icon(
                          AppIcons.calendar,
                          size: 16,
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                        AppSpacing.hGapXs,
                        Text(
                          '${event.formattedDate} • ${event.formattedTime}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGapXxs,

                    // Location
                    Row(
                      children: [
                        Icon(
                          AppIcons.location,
                          size: 16,
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                        AppSpacing.hGapXs,
                        Expanded(
                          child: Text(
                            event.location,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    this.isPast = false,
  });

  final Event event;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.cardBorderRadius,
        boxShadow: AppShadows.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.cardBorderRadius,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
          ),
          borderRadius: AppRadius.cardBorderRadius,
          child: Padding(
            padding: AppSpacing.cardPaddingAll,
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: AppRadius.borderRadiusMd,
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: event.coverImageUrl != null
                        ? Image.network(
                            event.coverImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.neutral200,
                              child: Icon(
                                AppIcons.events,
                                color: AppColors.neutral400,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.neutral200,
                            child: Icon(
                              AppIcons.events,
                              color: AppColors.neutral400,
                            ),
                          ),
                  ),
                ),
                AppSpacing.hGapMd,

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppBadge(
                            label: event.categoryLabel,
                            variant: isPast
                                ? AppBadgeVariant.info
                                : AppBadgeVariant.secondary,
                            size: AppBadgeSize.small,
                          ),
                          if (isPast) ...[
                            AppSpacing.hGapXs,
                            AppBadge(
                              label: 'Terminé',
                              variant: AppBadgeVariant.info,
                              size: AppBadgeSize.small,
                            ),
                          ],
                          if (!isPast && event.isFree) ...[
                            AppSpacing.hGapXs,
                            AppBadge(
                              label: 'Gratuit',
                              variant: AppBadgeVariant.success,
                              size: AppBadgeSize.small,
                            ),
                          ],
                        ],
                      ),
                      AppSpacing.vGapXs,
                      Text(
                        event.title,
                        style: AppTypography.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vGapXxs,
                      Row(
                        children: [
                          Icon(
                            AppIcons.calendar,
                            size: 14,
                            color: AppColors.iconSecondary,
                          ),
                          AppSpacing.hGapXxs,
                          Expanded(
                            child: Text(
                              event.formattedDate,
                              style: AppTypography.caption,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vGapXxs,
                      Row(
                        children: [
                          Icon(
                            AppIcons.clock,
                            size: 14,
                            color: AppColors.iconSecondary,
                          ),
                          AppSpacing.hGapXxs,
                          Text(
                            event.formattedTime,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  AppIcons.chevronRight,
                  color: AppColors.iconTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
