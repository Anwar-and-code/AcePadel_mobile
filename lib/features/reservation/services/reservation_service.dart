import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ReservationService {
  static final _supabase = Supabase.instance.client;

  static Future<List<Terrain>> getTerrains({bool activeOnly = true}) async {
    try {
      var query = _supabase.from('terrains').select();
      
      if (activeOnly) {
        query = query.eq('is_active', true);
      }
      
      final response = await query.order('code');
      
      return (response as List)
          .map((json) => Terrain.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ReservationException('Erreur lors du chargement des terrains: $e');
    }
  }

  static Future<List<TimeSlot>> getTimeSlots({bool activeOnly = true}) async {
    try {
      var query = _supabase.from('time_slots').select();
      
      if (activeOnly) {
        query = query.eq('is_active', true);
      }
      
      final response = await query.order('start_time');
      
      return (response as List)
          .map((json) => TimeSlot.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ReservationException('Erreur lors du chargement des créneaux: $e');
    }
  }

  static Future<List<AvailableSlot>> getAvailableSlotsForDate(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      
      final response = await _supabase
          .rpc('get_available_slots', params: {'p_date': dateStr});
      
      return (response as List)
          .map((json) => AvailableSlot.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ReservationException('Erreur lors du chargement des créneaux: $e');
    }
  }

  static Future<List<AvailableSlot>> getAvailableSlotsForDateAndTerrain(
    DateTime date,
    int terrainId,
  ) async {
    try {
      final allSlots = await getAvailableSlotsForDate(date);
      return allSlots.where((s) => s.terrainId == terrainId).toList();
    } catch (e) {
      throw ReservationException('Erreur lors du chargement des créneaux: $e');
    }
  }

  static Future<Map<int, List<AvailableSlot>>> getAvailableSlotsGroupedByTerrain(DateTime date) async {
    try {
      final slots = await getAvailableSlotsForDate(date);
      final Map<int, List<AvailableSlot>> grouped = {};
      
      for (final slot in slots) {
        grouped.putIfAbsent(slot.terrainId, () => []);
        grouped[slot.terrainId]!.add(slot);
      }
      
      return grouped;
    } catch (e) {
      throw ReservationException('Erreur lors du chargement des créneaux: $e');
    }
  }

  static Future<Map<int, int>> getAvailableSlotCountByTerrain(DateTime date) async {
    try {
      final slots = await getAvailableSlotsForDate(date);
      final Map<int, int> counts = {};
      
      for (final slot in slots) {
        counts.putIfAbsent(slot.terrainId, () => 0);
        if (!slot.isReserved) {
          counts[slot.terrainId] = counts[slot.terrainId]! + 1;
        }
      }
      
      return counts;
    } catch (e) {
      throw ReservationException('Erreur lors du chargement des créneaux: $e');
    }
  }

  static Future<Reservation> createReservation({
    required int terrainId,
    required int timeSlotId,
    required DateTime date,
    required String userId,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];

      final response = await _supabase
          .from('reservations')
          .insert({
            'terrain_id': terrainId,
            'time_slot_id': timeSlotId,
            'reservation_date': dateStr,
            'user_id': userId,
            'status': 'CONFIRMED',
          })
          .select('''
            *,
            terrains!inner(code),
            time_slots!inner(start_time, end_time, price)
          ''')
          .single();
      
      return Reservation.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw ReservationException('Ce créneau est déjà réservé');
      }
      throw ReservationException('Erreur lors de la réservation: ${e.message}');
    } catch (e) {
      if (e is ReservationException) rethrow;
      throw ReservationException('Erreur lors de la réservation: $e');
    }
  }

  static Future<List<Reservation>> getUserReservations(String userId) async {
    try {
      final response = await _supabase
          .from('reservations')
          .select('''
            *,
            terrains!inner(code),
            time_slots!inner(start_time, end_time, price)
          ''')
          .eq('user_id', userId)
          .order('reservation_date', ascending: false)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ReservationException('Erreur lors du chargement des réservations: $e');
    }
  }

  static Future<List<Reservation>> getUpcomingReservations(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final response = await _supabase
          .from('reservations')
          .select('''
            *,
            terrains!inner(code),
            time_slots!inner(start_time, end_time, price)
          ''')
          .eq('user_id', userId)
          .gte('reservation_date', today)
          .inFilter('status', ['CONFIRMED', 'PENDING'])
          .order('reservation_date')
          .order('time_slots(start_time)');
      
      return (response as List)
          .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ReservationException('Erreur lors du chargement des réservations: $e');
    }
  }

  static Future<List<Reservation>> getPastReservations(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final response = await _supabase
          .from('reservations')
          .select('''
            *,
            terrains!inner(code),
            time_slots!inner(start_time, end_time, price)
          ''')
          .eq('user_id', userId)
          .lt('reservation_date', today)
          .order('reservation_date', ascending: false);
      
      return (response as List)
          .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ReservationException('Erreur lors du chargement des réservations: $e');
    }
  }

  static Future<Reservation> cancelReservation(int reservationId) async {
    try {
      final response = await _supabase
          .from('reservations')
          .update({'status': 'CANCELED'})
          .eq('id', reservationId)
          .select('''
            *,
            terrains!inner(code),
            time_slots!inner(start_time, end_time, price)
          ''')
          .single();
      
      return Reservation.fromJson(response);
    } catch (e) {
      throw ReservationException('Erreur lors de l\'annulation: $e');
    }
  }

  static Future<bool> isSlotAvailable({
    required int terrainId,
    required int timeSlotId,
    required DateTime date,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      
      final response = await _supabase
          .from('reservations')
          .select('id')
          .eq('terrain_id', terrainId)
          .eq('time_slot_id', timeSlotId)
          .eq('reservation_date', dateStr)
          .inFilter('status', ['CONFIRMED', 'PENDING'])
          .maybeSingle();
      
      return response == null;
    } catch (e) {
      return false;
    }
  }
}

class ReservationException implements Exception {
  final String message;
  
  ReservationException(this.message);
  
  @override
  String toString() => message;
}
