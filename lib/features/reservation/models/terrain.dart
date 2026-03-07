import 'package:flutter/foundation.dart';

@immutable
class Court {
  final int id;
  final String code;
  final bool isActive;
  final DateTime createdAt;

  const Court({
    required this.id,
    required this.code,
    required this.isActive,
    required this.createdAt,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'] as int,
      code: json['code'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Court copyWith({
    int? id,
    String? code,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Court(
      id: id ?? this.id,
      code: code ?? this.code,
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
  String toString() => 'Court(id: $id, code: $code, isActive: $isActive)';
}
