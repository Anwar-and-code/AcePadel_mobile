import 'package:flutter/foundation.dart';

@immutable
class Terrain {
  final int id;
  final String code;
  final bool isActive;
  final DateTime createdAt;

  const Terrain({
    required this.id,
    required this.code,
    required this.isActive,
    required this.createdAt,
  });

  factory Terrain.fromJson(Map<String, dynamic> json) {
    return Terrain(
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

  Terrain copyWith({
    int? id,
    String? code,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Terrain(
      id: id ?? this.id,
      code: code ?? this.code,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Terrain && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Terrain(id: $id, code: $code, isActive: $isActive)';
}
