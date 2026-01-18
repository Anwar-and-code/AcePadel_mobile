import '../../../core/design_system/design_system.dart';

enum BookingStatus {
  upcoming,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case BookingStatus.upcoming:
        return 'À venir';
      case BookingStatus.completed:
        return 'Terminée';
      case BookingStatus.cancelled:
        return 'Annulée';
    }
  }

  AppBadgeVariant get badgeVariant {
    switch (this) {
      case BookingStatus.upcoming:
        return AppBadgeVariant.warning;
      case BookingStatus.completed:
        return AppBadgeVariant.success;
      case BookingStatus.cancelled:
        return AppBadgeVariant.error;
    }
  }
}

class Booking {
  final String reference;
  final String courtName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final double price;
  final BookingStatus status;

  Booking({
    required this.reference,
    required this.courtName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.status,
  });
}
