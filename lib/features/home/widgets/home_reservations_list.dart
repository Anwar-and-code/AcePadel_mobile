import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../reservation/models/booking.dart';
import '../../reservation/widgets/booking_details_modal.dart';

// Widget for active/upcoming reservation only
class HomeActiveReservation extends StatelessWidget {
  const HomeActiveReservation({super.key});

  // Sample data - in real app, this would come from a service
  static const int _upcomingCount = 1;

  void _showReservationDetails(BuildContext context) {
    // Create a temporary booking object for the active reservation
    final booking = Booking(
      reference: 'WP-X0126',
      courtName: 'A',
      date: DateTime(2026, 1, 8), // 8 Jan 2026
      startTime: '19:00',
      endTime: '20:30',
      price: 25000,
      status: BookingStatus.upcoming,
    );

    showBookingDetailsModal(context, booking);
  }

  @override
  Widget build(BuildContext context) {
    if (_upcomingCount == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with badge
        Row(
          children: [
            Expanded(
              child: AppSectionHeader(
                title: 'Réservations',
                action: 'Voir tout',
                onActionTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(AppIcons.calendar, color: AppColors.white),
                          AppSpacing.hGapSm,
                          Expanded(
                              child: Text(
                                  'Rendez-vous dans l\'onglet "Réservations"')),
                        ],
                      ),
                      backgroundColor: AppColors.brandPrimary,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        AppSpacing.vGapMd,

        // Upcoming reservation highlight
        _UpcomingReservationCard(
          courtName: 'A',
          date: 'Mer 8 Jan',
          startTime: '19:00',
          endTime: '20:30',
          price: '25 000 F',
          onTap: () {
            _showReservationDetails(context);
          },
        ),
      ],
    );
  }
}

// Widget for reservation history
class HomeReservationsHistory extends StatelessWidget {
  const HomeReservationsHistory({super.key});

  void _showHistoryDetails(BuildContext context, Booking booking) {
    showBookingDetailsModal(context, booking);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Historique récent'),
        AppSpacing.vGapMd,
        _ReservationCard(
          reference: 'WP-X0125',
          courtName: 'A',
          date: '6 Jan 2026',
          startTime: '13:00',
          endTime: '14:00',
          price: '15 000 F',
          onTap: () {
             final booking = Booking(
              reference: 'WP-X0125',
              courtName: 'A',
              date: DateTime(2026, 1, 6),
              startTime: '13:00',
              endTime: '14:00',
              price: 15000,
              status: BookingStatus.completed,
            );
            _showHistoryDetails(context, booking);
          },
        ),
        AppSpacing.vGapSm,
        _ReservationCard(
          reference: 'WP-X0124',
          courtName: 'B',
          date: '3 Jan 2026',
          startTime: '16:00',
          endTime: '17:30',
          price: '20 000 F',
          onTap: () {
             final booking = Booking(
              reference: 'WP-X0124',
              courtName: 'B',
              date: DateTime(2026, 1, 3),
              startTime: '16:00',
              endTime: '17:30',
              price: 20000,
              status: BookingStatus.completed,
            );
            _showHistoryDetails(context, booking);
          },
        ),
      ],
    );
  }
}

// Highlighted card for upcoming reservation
class _UpcomingReservationCard extends StatelessWidget {
  const _UpcomingReservationCard({
    required this.courtName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.price,
    this.onTap,
  });

  final String courtName;
  final String date;
  final String startTime;
  final String endTime;
  final String price;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brandOlive,
            AppColors.brandOlive.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: AppColors.brandOlive.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.borderRadiusMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderRadiusMd,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: AppRadius.borderRadiusFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.calendarFilled,
                            color: AppColors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Prochaine réservation',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      AppIcons.chevronRight,
                      color: AppColors.white.withValues(alpha: 0.8),
                      size: 20,
                    ),
                  ],
                ),
                AppSpacing.vGapMd,

                // Main content
                Row(
                  children: [
                    // Court badge
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: Center(
                        child: Text(
                          courtName,
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.brandOlive,
                            fontWeight: FontWeight.bold,
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
                          Text(
                            date,
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppSpacing.vGapXxs,
                          Text(
                            '$startTime - $endTime',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Text(
                      price,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reference,
    required this.courtName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.price,
    this.onTap,
  });

  final String reference;
  final String courtName;
  final String date;
  final String startTime;
  final String endTime;
  final String price;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.cardBorderRadius,
        border: Border.all(color: AppColors.reservationCardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.cardBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardBorderRadius,
          child: Row(
            children: [
              // Time badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.reservationTimeBadge,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.card - 1),
                    bottomLeft: Radius.circular(AppRadius.card - 1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      startTime,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      endTime,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        date,
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.vGapXxs,
                      Text(
                        'Terrain $courtName',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Arrow
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Icon(
                  AppIcons.chevronRight,
                  color: AppColors.iconTertiary,
                  size: AppIcons.sizeMd,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
