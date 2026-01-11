class Event {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String imageUrl;
  final int participants;
  final int maxParticipants;
  final String category;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.imageUrl,
    required this.participants,
    required this.maxParticipants,
    required this.category,
  });
}
