import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';

/// Service pour récupérer les événements depuis Supabase
class EventService extends ChangeNotifier {
  static final EventService instance = EventService._();

  EventService._();

  static SupabaseClient get _supabase => Supabase.instance.client;

  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// All upcoming events (sorted by start_date)
  List<Event> get upcomingEvents =>
      _events.where((e) => e.isUpcoming).toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));

  /// Past events (sorted by start_date descending)
  List<Event> get pastEvents =>
      _events.where((e) => !e.isUpcoming).toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));

  /// Featured event (first featured upcoming, or first upcoming)
  Event? get featuredEvent {
    final upcoming = upcomingEvents;
    if (upcoming.isEmpty) return null;
    return upcoming.firstWhere(
      (e) => e.isFeatured,
      orElse: () => upcoming.first,
    );
  }

  /// Non-featured upcoming events
  List<Event> get nonFeaturedUpcomingEvents {
    final featured = featuredEvent;
    return upcomingEvents.where((e) => e.id != featured?.id).toList();
  }

  /// Charge tous les événements publiés avec leurs images
  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('events')
          .select('*, event_images(*)')
          .eq('status', 'PUBLISHED')
          .order('display_order', ascending: true);

      _events = (response as List<dynamic>)
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = 'Erreur lors du chargement des événements';
      debugPrint('Error loading events: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Charge un seul événement par ID
  Future<Event?> getEvent(String id) async {
    try {
      final response = await _supabase
          .from('events')
          .select('*, event_images(*)')
          .eq('id', id)
          .eq('status', 'PUBLISHED')
          .maybeSingle();

      if (response != null) {
        return Event.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error loading event $id: $e');
    }
    return null;
  }

  /// Réinitialiser le service
  void reset() {
    _events = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
