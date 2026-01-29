import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/coach.dart';

class CoachingService {
  static final _supabase = Supabase.instance.client;

  static Future<List<Coach>> getCoaches({bool activeOnly = true}) async {
    try {
      var query = _supabase.from('coaches').select();

      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      final response = await query.order('first_name');

      return (response as List)
          .map((json) => Coach.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CoachingException('Erreur lors du chargement des coaches: $e');
    }
  }

  static Future<Coach?> getCoachById(String id) async {
    try {
      final response = await _supabase
          .from('coaches')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Coach.fromJson(response);
    } catch (e) {
      throw CoachingException('Erreur lors du chargement du coach: $e');
    }
  }
}

class CoachingException implements Exception {
  final String message;

  CoachingException(this.message);

  @override
  String toString() => message;
}
