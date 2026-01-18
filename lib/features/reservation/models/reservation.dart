import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

enum ReservationStatus {
  pending,
  confirmed,
  canceled,
  expired;

  static ReservationStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return ReservationStatus.pending;
      case 'CONFIRMED':
        return ReservationStatus.confirmed;
      case 'CANCELED':
        return ReservationStatus.canceled;
      case 'EXPIRED':
        return ReservationStatus.expired;
      default:
        return ReservationStatus.pending;
    }
  }

  String toDbString() {
    return name.toUpperCase();
  }

  String get label {
    switch (this) {
      case ReservationStatus.pending:
        return 'En attente';
      case ReservationStatus.confirmed:
        return 'Confirmée';
      case ReservationStatus.canceled:
        return 'Annulée';
      case ReservationStatus.expired:
        return 'Expirée';
    }
  }

  AppBadgeVariant get badgeVariant {
    switch (this) {
      case ReservationStatus.pending:
        return AppBadgeVariant.warning;
      case ReservationStatus.confirmed:
        return AppBadgeVariant.success;
      case ReservationStatus.canceled:
        return AppBadgeVariant.error;
      case ReservationStatus.expired:
        return AppBadgeVariant.secondary;
    }
  }

  Color get color {
    switch (this) {
      case ReservationStatus.pending:
        return AppColors.warning;
      case ReservationStatus.confirmed:
        return AppColors.success;
      case ReservationStatus.canceled:
        return AppColors.error;
      case ReservationStatus.expired:
        return AppColors.neutral400;
    }
  }

  IconData get icon {
    switch (this) {
      case ReservationStatus.pending:
        return Icons.schedule;
      case ReservationStatus.confirmed:
        return Icons.check_circle;
      case ReservationStatus.canceled:
        return Icons.cancel;
      case ReservationStatus.expired:
        return Icons.timer_off;
    }
  }
}

@immutable
class Reservation {
  final int id;
  final int terrainId;
  final int timeSlotId;
  final DateTime reservationDate;
  final String userId;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? terrainCode;
  final String? startTime;
  final String? endTime;
  final int? price;

  const Reservation({
    required this.id,
    required this.terrainId,
    required this.timeSlotId,
    required this.reservationDate,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.terrainCode,
    this.startTime,
    this.endTime,
    this.price,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final terrainData = json['terrains'] as Map<String, dynamic>?;
    final timeSlotData = json['time_slots'] as Map<String, dynamic>?;

    return Reservation(
      id: json['id'] as int,
      terrainId: json['terrain_id'] as int,
      timeSlotId: json['time_slot_id'] as int,
      reservationDate: DateTime.parse(json['reservation_date'] as String),
      userId: json['user_id'] as String,
      status: ReservationStatus.fromString(json['status'] as String? ?? 'PENDING'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      terrainCode: terrainData?['code'] as String?,
      startTime: timeSlotData?['start_time'] as String?,
      endTime: timeSlotData?['end_time'] as String?,
      price: timeSlotData?['price'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'terrain_id': terrainId,
      'time_slot_id': timeSlotId,
      'reservation_date': reservationDate.toIso8601String().split('T')[0],
      'user_id': userId,
      'status': status.toDbString(),
    };
  }

  String get formattedStartTime {
    if (startTime == null) return '--:--';
    final parts = startTime!.split(':');
    return '${parts[0]}:${parts[1]}';
  }

  String get formattedEndTime {
    if (endTime == null) return '--:--';
    final parts = endTime!.split(':');
    return '${parts[0]}:${parts[1]}';
  }

  String get reference {
    final day = reservationDate.day.toString().padLeft(2, '0');
    final month = reservationDate.month.toString().padLeft(2, '0');
    final year = (reservationDate.year % 100).toString().padLeft(2, '0');
    final seq = id.toString().padLeft(3, '0');
    return 'R-$day$month$year-$seq';
  }

  bool get isUpcoming {
    if (status == ReservationStatus.canceled || status == ReservationStatus.expired) {
      return false;
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final resDate = DateTime(reservationDate.year, reservationDate.month, reservationDate.day);
    
    // Si la date est dans le futur, c'est à venir
    if (resDate.isAfter(today)) return true;
    
    // Si c'est aujourd'hui, vérifier l'heure de fin
    if (resDate.isAtSameMomentAs(today)) {
      if (endTime == null) return false;
      
      final parts = endTime!.split(':');
      final endHour = int.tryParse(parts[0]) ?? 0;
      final endMinute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      
      // La réservation est à venir si l'heure de fin n'est pas encore passée
      final endDateTime = DateTime(now.year, now.month, now.day, endHour, endMinute);
      return now.isBefore(endDateTime);
    }
    
    // Date passée
    return false;
  }

  bool get canCancel {
    if (!isUpcoming) return false;
    if (status != ReservationStatus.confirmed && status != ReservationStatus.pending) return false;
    if (startTime == null) return false;
    
    final parts = startTime!.split(':');
    final slotDateTime = DateTime(
      reservationDate.year,
      reservationDate.month,
      reservationDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    return slotDateTime.difference(DateTime.now()).inHours >= 2;
  }

  Reservation copyWith({
    int? id,
    int? terrainId,
    int? timeSlotId,
    DateTime? reservationDate,
    String? userId,
    ReservationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? terrainCode,
    String? startTime,
    String? endTime,
    int? price,
  }) {
    return Reservation(
      id: id ?? this.id,
      terrainId: terrainId ?? this.terrainId,
      timeSlotId: timeSlotId ?? this.timeSlotId,
      reservationDate: reservationDate ?? this.reservationDate,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      terrainCode: terrainCode ?? this.terrainCode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      price: price ?? this.price,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reservation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Reservation(id: $id, status: $status, terrain: $terrainCode)';
}
