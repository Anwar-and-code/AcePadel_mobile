import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../models/booking.dart';

void showBookingDetailsModal(BuildContext context, Booking booking) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.backgroundPrimary,
    isScrollControlled: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (context) => BookingDetailsModal(booking: booking),
  );
}

class BookingDetailsModal extends StatelessWidget {
  final Booking booking;

  const BookingDetailsModal({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDefault,
                borderRadius: AppRadius.borderRadiusFull,
              ),
            ),
          ),
          AppSpacing.vGapLg,

          // Header with title and badge
          Row(
            children: [
              Text(
                'Détails de la réservation',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.hGapMd,
              AppBadge(
                label: booking.status.label,
                variant: booking.status.badgeVariant,
              ),
            ],
          ),

          AppSpacing.vGapXl,

          // Details with colored icons
          _CompactDetailRow(
            icon: Icons.tag,
            iconColor: AppColors.brandOlive,
            label: 'Référence',
            value: booking.reference,
          ),
          AppSpacing.vGapMd,
          _CompactDetailRow(
            icon: Icons.calendar_today,
            iconColor: AppColors.brandOlive,
            label: 'Date',
            value: _formatDate(booking.date),
          ),
          AppSpacing.vGapMd,
          _CompactDetailRow(
            icon: Icons.access_time_filled,
            iconColor: AppColors.info,
            label: 'Créneau',
            value: '${booking.startTime} - ${booking.endTime}',
          ),
          AppSpacing.vGapMd,
          _CompactDetailRow(
            icon: Icons.sports_tennis,
            iconColor: AppColors.success,
            label: 'Terrain',
            value: 'Terrain ${booking.courtName}',
          ),
          AppSpacing.vGapMd,
          _CompactDetailRow(
            icon: Icons.payments,
            iconColor: AppColors.warning,
            label: 'Prix',
            value: _formatPrice(booking.price),
          ),

          AppSpacing.vGapXl,

          // Close button
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Fermer',
              variant: AppButtonVariant.primary,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final dayNames = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];
    final monthNames = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];

    return '${dayNames[date.weekday - 1]} ${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    return '$intPrice FCFA';
  }
}

class _CompactDetailRow extends StatelessWidget {
  const _CompactDetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: AppRadius.borderRadiusMd,
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
