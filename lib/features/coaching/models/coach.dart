import 'package:flutter/foundation.dart';

@immutable
class Coach {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? imageUrl;
  final String? bio;
  final bool isActive;
  final int price1hSolo;
  final int price1h30Solo;
  final int price1hDuo;
  final int price1h30Duo;
  final int price1hTrio;
  final int price1h30Trio;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Coach({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.imageUrl,
    this.bio,
    required this.isActive,
    required this.price1hSolo,
    required this.price1h30Solo,
    required this.price1hDuo,
    required this.price1h30Duo,
    required this.price1hTrio,
    required this.price1h30Trio,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String,
      imageUrl: json['image_url'] as String?,
      bio: json['bio'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      price1hSolo: json['price_1h_solo'] as int? ?? 0,
      price1h30Solo: json['price_1h30_solo'] as int? ?? 0,
      price1hDuo: json['price_1h_duo'] as int? ?? 0,
      price1h30Duo: json['price_1h30_duo'] as int? ?? 0,
      price1hTrio: json['price_1h_trio'] as int? ?? 0,
      price1h30Trio: json['price_1h30_trio'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'image_url': imageUrl,
      'bio': bio,
      'is_active': isActive,
      'price_1h_solo': price1hSolo,
      'price_1h30_solo': price1h30Solo,
      'price_1h_duo': price1hDuo,
      'price_1h30_duo': price1h30Duo,
      'price_1h_trio': price1hTrio,
      'price_1h30_trio': price1h30Trio,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String formatPrice(int price) {
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

  String get formattedPrice1hSolo => formatPrice(price1hSolo);
  String get formattedPrice1h30Solo => formatPrice(price1h30Solo);
  String get formattedPrice1hDuo => formatPrice(price1hDuo);
  String get formattedPrice1h30Duo => formatPrice(price1h30Duo);
  String get formattedPrice1hTrio => formatPrice(price1hTrio);
  String get formattedPrice1h30Trio => formatPrice(price1h30Trio);

  Coach copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? imageUrl,
    String? bio,
    bool? isActive,
    int? price1hSolo,
    int? price1h30Solo,
    int? price1hDuo,
    int? price1h30Duo,
    int? price1hTrio,
    int? price1h30Trio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Coach(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      bio: bio ?? this.bio,
      isActive: isActive ?? this.isActive,
      price1hSolo: price1hSolo ?? this.price1hSolo,
      price1h30Solo: price1h30Solo ?? this.price1h30Solo,
      price1hDuo: price1hDuo ?? this.price1hDuo,
      price1h30Duo: price1h30Duo ?? this.price1h30Duo,
      price1hTrio: price1hTrio ?? this.price1hTrio,
      price1h30Trio: price1h30Trio ?? this.price1h30Trio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Coach && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Coach(id: $id, name: $fullName)';
}
