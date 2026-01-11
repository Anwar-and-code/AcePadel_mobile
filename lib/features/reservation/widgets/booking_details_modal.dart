import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../models/booking.dart';

void showBookingDetailsModal(BuildContext context, Booking booking) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.backgroundPrimary,
    isScrollControlled: true,
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
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
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

              // Header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.brandSecondary,
                      borderRadius: AppRadius.borderRadiusMd,
                    ),
                    child: Center(
                      child: Text(
                        booking.courtName,
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.hGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terrain ${booking.courtName}',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'PadelHouse Cocody',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppBadge(
                    label: booking.status.label,
                    variant: booking.status.badgeVariant,
                  ),
                ],
              ),

              AppSpacing.vGapXl,

              // Details
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Date',
                value: _formatDate(booking.date),
              ),
              _DetailRow(
                icon: Icons.access_time,
                label: 'Horaire',
                value: '${booking.startTime} - ${booking.endTime}',
              ),
              _DetailRow(
                icon: Icons.timer,
                label: 'Durée',
                value: _calculateDuration(booking.startTime, booking.endTime),
              ),
              _DetailRow(
                icon: Icons.payments,
                label: 'Montant',
                value: _formatPrice(booking.price),
              ),
              _DetailRow(
                icon: Icons.confirmation_number,
                label: 'Référence',
                value: booking.reference,
              ),

              AppSpacing.vGapXl,

              // QR Code section (only for upcoming or completed)
              if (booking.status != BookingStatus.cancelled) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.qr_code_2,
                          size: 80, color: AppColors.brandPrimary),
                      AppSpacing.vGapSm,
                      Text(
                        'Présentez ce QR code à l\'accueil',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vGapXl,
              ],

              // Actions
              if (booking.status == BookingStatus.upcoming) ...[
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Modifier',
                        variant: AppButtonVariant.outline,
                        icon: Icons.edit,
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Redirection vers la modification...'),
                              backgroundColor: AppColors.brandPrimary,
                            ),
                          );
                        },
                      ),
                    ),
                    AppSpacing.hGapMd,
                    Expanded(
                      child: AppButton(
                        label: 'Annuler',
                        variant: AppButtonVariant.outline,
                        icon: Icons.close,
                        onPressed: () {
                          Navigator.pop(context);
                          _showCancelDialog(context);
                        },
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGapLg,
              ],
            ],
          ),
        ),
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

  String _calculateDuration(String start, String end) {
    // Simple parsing assuming HH:MM format
    final startParts = start.split(':');
    final endParts = end.split(':');
    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    final diff = endMinutes - startMinutes;
    final hours = diff ~/ 60;
    final minutes = diff % 60;

    if (minutes == 0) return '${hours}h';
    return '${hours}h${minutes.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    if (intPrice >= 1000) {
      final thousands = intPrice ~/ 1000;
      final remainder = intPrice % 1000;
      if (remainder == 0) {
        return '$thousands 000 F CFA';
      }
      return '$thousands ${remainder.toString().padLeft(3, '0')} F CFA';
    }
    return '$intPrice F CFA';
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Annuler la réservation ?'),
        content: Text('Vous pouvez annuler gratuitement jusqu\'à 24h avant.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Non'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Réservation annulée'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            child: Text('Oui, annuler', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.iconSecondary),
          AppSpacing.hGapMd,
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
