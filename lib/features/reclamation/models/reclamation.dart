/// Modèle pour une réclamation utilisateur
class Reclamation {
  final String id;
  final String userId;
  final String subject;
  final String description;
  final ReclamationCategory category;
  final ReclamationStatus status;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final String? adminResponse;

  Reclamation({
    required this.id,
    required this.userId,
    required this.subject,
    required this.description,
    required this.category,
    required this.status,
    this.photoUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.adminResponse,
  });

  factory Reclamation.fromJson(Map<String, dynamic> json) {
    return Reclamation(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      category: ReclamationCategory.fromString(json['category']),
      status: ReclamationStatus.fromString(json['status']),
      photoUrls: json['photo_urls'] != null 
          ? List<String>.from(json['photo_urls']) 
          : [],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      resolvedAt: json['resolved_at'] != null 
          ? DateTime.parse(json['resolved_at']) 
          : null,
      adminResponse: json['admin_response'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subject': subject,
      'description': description,
      'category': category.value,
      'status': status.value,
      'photo_urls': photoUrls,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'admin_response': adminResponse,
    };
  }

  Reclamation copyWith({
    String? id,
    String? userId,
    String? subject,
    String? description,
    ReclamationCategory? category,
    ReclamationStatus? status,
    List<String>? photoUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    String? adminResponse,
  }) {
    return Reclamation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      adminResponse: adminResponse ?? this.adminResponse,
    );
  }
}

/// Catégories de réclamation
enum ReclamationCategory {
  general('general', 'Général'),
  reservation('reservation', 'Réservation'),
  terrain('terrain', 'Court'),
  paiement('paiement', 'Paiement'),
  autre('autre', 'Autre');

  final String value;
  final String label;

  const ReclamationCategory(this.value, this.label);

  static ReclamationCategory fromString(String? value) {
    return ReclamationCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReclamationCategory.general,
    );
  }
}

/// Statuts de réclamation
enum ReclamationStatus {
  pending('pending', 'En attente', 0xFFFFA726),
  inProgress('in_progress', 'En cours', 0xFF42A5F5),
  resolved('resolved', 'Résolu', 0xFF66BB6A),
  rejected('rejected', 'Rejeté', 0xFFEF5350);

  final String value;
  final String label;
  final int colorValue;

  const ReclamationStatus(this.value, this.label, this.colorValue);

  static ReclamationStatus fromString(String? value) {
    return ReclamationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReclamationStatus.pending,
    );
  }
}
