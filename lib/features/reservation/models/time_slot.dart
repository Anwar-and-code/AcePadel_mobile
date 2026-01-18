import 'package:flutter/foundation.dart';

@immutable
class TimeSlot {
  final int id;
  final String startTime;
  final String endTime;
  final int price;
  final bool isActive;
  final DateTime createdAt;

  const TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.isActive,
    required this.createdAt,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      price: json['price'] as int? ?? 10000,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime,
      'end_time': endTime,
      'price': price,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get formattedStartTime {
    final parts = startTime.split(':');
    return '${parts[0]}h${parts[1]}';
  }

  String get formattedEndTime {
    final parts = endTime.split(':');
    return '${parts[0]}h${parts[1]}';
  }

  String get timeRange => '$formattedStartTime - $formattedEndTime';

  String get displayTimeRange {
    final start = startTime.substring(0, 5);
    final end = endTime.substring(0, 5);
    return '$start - $end';
  }

  int get durationMinutes {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    return endMinutes - startMinutes;
  }

  String get formattedPrice {
    if (price >= 1000) {
      final thousands = price ~/ 1000;
      final remainder = price % 1000;
      if (remainder == 0) {
        return '$thousands 000 F.CFA';
      }
      return '$thousands ${remainder.toString().padLeft(3, '0')} F.CFA';
    }
    return '$price F.CFA';
  }

  TimeSlot copyWith({
    int? id,
    String? startTime,
    String? endTime,
    int? price,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeSlot && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TimeSlot(id: $id, $timeRange, price: $price)';
}

@immutable
class AvailableSlot {
  final int terrainId;
  final String terrainCode;
  final int timeSlotId;
  final String startTime;
  final String endTime;
  final int price;
  final bool isReserved;

  const AvailableSlot({
    required this.terrainId,
    required this.terrainCode,
    required this.timeSlotId,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.isReserved,
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) {
    return AvailableSlot(
      terrainId: json['terrain_id'] as int,
      terrainCode: json['terrain_code'] as String,
      timeSlotId: json['time_slot_id'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      price: json['price'] as int? ?? 10000,
      isReserved: json['is_reserved'] as bool? ?? false,
    );
  }

  String get formattedStartTime {
    final parts = startTime.split(':');
    return '${parts[0]}h${parts[1]}';
  }

  String get formattedEndTime {
    final parts = endTime.split(':');
    return '${parts[0]}h${parts[1]}';
  }

  String get timeRange => '$formattedStartTime - $formattedEndTime';

  String get formattedPrice {
    if (price >= 1000) {
      final thousands = price ~/ 1000;
      final remainder = price % 1000;
      if (remainder == 0) {
        return '$thousands 000 F.CFA';
      }
      return '$thousands ${remainder.toString().padLeft(3, '0')} F.CFA';
    }
    return '$price F.CFA';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AvailableSlot && 
           other.terrainId == terrainId && 
           other.timeSlotId == timeSlotId;
  }

  @override
  int get hashCode => Object.hash(terrainId, timeSlotId);

  @override
  String toString() => 'AvailableSlot(terrain: $terrainCode, $timeRange, reserved: $isReserved)';
}
