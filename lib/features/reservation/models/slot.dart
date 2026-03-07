import 'package:flutter/foundation.dart';

@immutable
class Slot {
  final int id;
  final int terrainId;
  final DateTime slotDate;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime createdAt;
  final bool isReserved;
  final String? terrainCode;

  const Slot({
    required this.id,
    required this.terrainId,
    required this.slotDate,
    required this.startAt,
    required this.endAt,
    required this.createdAt,
    this.isReserved = false,
    this.terrainCode,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['id'] as int,
      terrainId: json['terrain_id'] as int,
      slotDate: DateTime.parse(json['slot_date'] as String),
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: DateTime.parse(json['end_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      isReserved: json['is_reserved'] as bool? ?? false,
      terrainCode: json['terrain_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'terrain_id': terrainId,
      'slot_date': slotDate.toIso8601String().split('T')[0],
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get timeRange {
    final startHour = startAt.hour.toString().padLeft(2, '0');
    final startMin = startAt.minute.toString().padLeft(2, '0');
    final endHour = endAt.hour.toString().padLeft(2, '0');
    final endMin = endAt.minute.toString().padLeft(2, '0');
    return '$startHour:$startMin - $endHour:$endMin';
  }

  String get formattedStartTime {
    final hour = startAt.hour.toString().padLeft(2, '0');
    final min = startAt.minute.toString().padLeft(2, '0');
    return '${hour}h$min';
  }

  String get formattedEndTime {
    final hour = endAt.hour.toString().padLeft(2, '0');
    final min = endAt.minute.toString().padLeft(2, '0');
    return '${hour}h$min';
  }

  Duration get duration => endAt.difference(startAt);

  int get durationMinutes => duration.inMinutes;

  int calculatePrice() {
    final hour = startAt.hour;
    final durationHours = durationMinutes / 60;
    
    int basePrice;
    if (hour < 12) {
      basePrice = 10000;
    } else if (hour < 17) {
      basePrice = 12000;
    } else {
      basePrice = 15000;
    }
    
    return (basePrice * durationHours).round();
  }

  Slot copyWith({
    int? id,
    int? terrainId,
    DateTime? slotDate,
    DateTime? startAt,
    DateTime? endAt,
    DateTime? createdAt,
    bool? isReserved,
    String? terrainCode,
  }) {
    return Slot(
      id: id ?? this.id,
      terrainId: terrainId ?? this.terrainId,
      slotDate: slotDate ?? this.slotDate,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      createdAt: createdAt ?? this.createdAt,
      isReserved: isReserved ?? this.isReserved,
      terrainCode: terrainCode ?? this.terrainCode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Slot && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Slot(id: $id, courtId: $terrainId, $timeRange, reserved: $isReserved)';
}
