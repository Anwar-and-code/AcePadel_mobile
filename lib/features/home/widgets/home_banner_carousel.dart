import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../events/models/event.dart';
import '../../events/services/event_service.dart';
import '../../events/screens/event_detail_screen.dart';

class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({super.key});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  final PageController _pageController = PageController();
  final _eventService = EventService.instance;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _eventService.addListener(_onEventsChanged);
    if (_eventService.events.isEmpty) {
      _eventService.loadEvents();
    }
  }

  @override
  void dispose() {
    _eventService.removeListener(_onEventsChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onEventsChanged() {
    if (mounted) setState(() {});
  }

  List<Event> get _displayEvents => _eventService.upcomingEvents;

  @override
  Widget build(BuildContext context) {
    if (_eventService.isLoading && _displayEvents.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.brandPrimary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_displayEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _displayEvents.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: AppSpacing.screenPaddingHorizontalOnly,
                child: _EventBannerCard(
                  event: _displayEvents[index],
                  onNext: index < _displayEvents.length - 1
                      ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
                  onPrevious: index > 0
                      ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(
                          event: _displayEvents[index],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        AppSpacing.vGapMd,
        AppPageIndicator(
          count: _displayEvents.length,
          currentIndex: _currentPage,
        ),
      ],
    );
  }
}

class _EventBannerCard extends StatelessWidget {
  const _EventBannerCard({
    required this.event,
    this.onNext,
    this.onPrevious,
    this.onTap,
  });

  final Event event;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardBorderRadius,
        boxShadow: AppShadows.imageShadow,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.cardBorderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            GestureDetector(
              onTap: onTap,
              child: event.coverImageUrl != null
                  ? Image.network(
                      event.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.neutral200,
                        child: Center(
                          child: Icon(
                            AppIcons.events,
                            size: 48,
                            color: AppColors.neutral400,
                          ),
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.neutral100,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: AppColors.brandPrimary,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppColors.neutral200,
                      child: Center(
                        child: Icon(
                          AppIcons.events,
                          size: 48,
                          color: AppColors.neutral400,
                        ),
                      ),
                    ),
            ),

            // Bottom gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 24, 12, 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.75),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          AppBadge(
                            label: event.categoryLabel,
                            variant: AppBadgeVariant.secondary,
                            size: AppBadgeSize.small,
                          ),
                          if (event.isFree) ...[
                            const SizedBox(width: 6),
                            AppBadge(
                              label: 'Gratuit',
                              variant: AppBadgeVariant.success,
                              size: AppBadgeSize.small,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.title,
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(AppIcons.calendar, size: 12, color: AppColors.white.withValues(alpha: 0.8)),
                          const SizedBox(width: 4),
                          Text(
                            event.formattedDate,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(AppIcons.location, size: 12, color: AppColors.white.withValues(alpha: 0.8)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              style: AppTypography.caption.copyWith(
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
              ),
            ),

            // Navigation arrows
            if (onPrevious != null)
              Positioned(
                left: AppSpacing.sm,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavigationArrow(
                    icon: AppIcons.chevronLeft,
                    onTap: onPrevious,
                  ),
                ),
              ),
            if (onNext != null)
              Positioned(
                right: AppSpacing.sm,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavigationArrow(
                    icon: AppIcons.chevronRight,
                    onTap: onNext,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavigationArrow extends StatelessWidget {
  const _NavigationArrow({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.9),
      borderRadius: AppRadius.borderRadiusFull,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderRadiusFull,
        child: Container(
          padding: AppSpacing.paddingXs,
          child: Icon(
            icon,
            size: AppIcons.sizeMd,
            color: AppColors.iconPrimary,
          ),
        ),
      ),
    );
  }
}
