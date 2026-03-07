class Event {
  final String id;
  final String title;
  final String? subtitle;
  final String description;
  final String? longDescription;
  final String category;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final String? coverImageUrl;
  final bool isFeatured;
  final int displayOrder;
  final List<String> tags;
  final String? priceInfo;
  final bool isFree;
  final String? contactPhone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<EventImage> images;

  const Event({
    required this.id,
    required this.title,
    this.subtitle,
    required this.description,
    this.longDescription,
    required this.category,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.location,
    this.coverImageUrl,
    this.isFeatured = false,
    this.displayOrder = 0,
    this.tags = const [],
    this.priceInfo,
    this.isFree = true,
    this.contactPhone,
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final imagesList = (json['event_images'] as List<dynamic>?)
        ?.map((img) => EventImage.fromJson(img as Map<String, dynamic>))
        .toList()
      ?..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String,
      longDescription: json['long_description'] as String?,
      category: json['category'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      location: json['location'] as String,
      coverImageUrl: json['cover_image_url'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      displayOrder: json['display_order'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toList() ??
          [],
      priceInfo: json['price_info'] as String?,
      isFree: json['is_free'] as bool? ?? true,
      contactPhone: json['contact_phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      images: imagesList ?? [],
    );
  }

  /// Whether the event is upcoming (hasn't ended yet)
  bool get isUpcoming {
    final now = DateTime.now();
    final end = endDate ?? startDate;
    return end.isAfter(now);
  }

  /// Whether the event is currently happening
  bool get isOngoing {
    final now = DateTime.now();
    return startDate.isBefore(now) && (endDate?.isAfter(now) ?? false);
  }

  /// Formatted date string (e.g. "Sam 15 Mar 2026")
  String get formattedDate {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${days[startDate.weekday - 1]} ${startDate.day} ${months[startDate.month - 1]} ${startDate.year}';
  }

  /// Formatted time range (e.g. "09:00 - 18:00")
  String get formattedTime {
    final start =
        '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}';
    if (endDate != null) {
      final end =
          '${endDate!.hour.toString().padLeft(2, '0')}:${endDate!.minute.toString().padLeft(2, '0')}';
      return '$start - $end';
    }
    return start;
  }

  /// Category display label
  String get categoryLabel {
    switch (category) {
      case 'TOURNOI':
        return 'Tournoi';
      case 'FORMATION':
        return 'Formation';
      case 'SOCIAL':
        return 'Social';
      case 'ANIMATION':
        return 'Animation';
      case 'COMPETITION':
        return 'Compétition';
      default:
        return 'Autre';
    }
  }
}

class EventImage {
  final String id;
  final String eventId;
  final String imageUrl;
  final String? caption;
  final int displayOrder;

  const EventImage({
    required this.id,
    required this.eventId,
    required this.imageUrl,
    this.caption,
    this.displayOrder = 0,
  });

  factory EventImage.fromJson(Map<String, dynamic> json) {
    return EventImage(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      imageUrl: json['image_url'] as String,
      caption: json['caption'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }
}
