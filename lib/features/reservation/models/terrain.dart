import 'package:flutter/foundation.dart';

@immutable
class Court {
  final int id;
  final String code;
  final String courtType;
  final int priceBefore16;
  final int priceFrom16;
  final bool isActive;
  final DateTime createdAt;

  const Court({
    required this.id,
    required this.code,
    this.courtType = 'simple',
    this.priceBefore16 = 15000,
    this.priceFrom16 = 20000,
    required this.isActive,
    required this.createdAt,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'] as int,
      code: json['code'] as String,
      courtType: json['court_type'] as String? ?? 'simple',
      priceBefore16: json['price_before_16'] as int? ?? 15000,
      priceFrom16: json['price_from_16'] as int? ?? 20000,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'court_type': courtType,
      'price_before_16': priceBefore16,
      'price_from_16': priceFrom16,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isDouble => courtType == 'double';
  bool get isSimple => courtType == 'simple';

  String get formattedPriceBefore16 => _formatPrice(priceBefore16);
  String get formattedPriceFrom16 => _formatPrice(priceFrom16);

  static String _formatPrice(int price) {
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

  Court copyWith({
    int? id,
    String? code,
    String? courtType,
    int? priceBefore16,
    int? priceFrom16,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Court(
      id: id ?? this.id,
      code: code ?? this.code,
      courtType: courtType ?? this.courtType,
      priceBefore16: priceBefore16 ?? this.priceBefore16,
      priceFrom16: priceFrom16 ?? this.priceFrom16,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Court && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Court(id: $id, code: $code, type: $courtType, isActive: $isActive)';
}
