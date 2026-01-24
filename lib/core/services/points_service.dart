import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service simple pour gérer les points utilisateur
/// - Créneau 1h = 1 point
/// - Créneau 1h30 = 2 points
class PointsService extends ChangeNotifier {
  PointsService._();
  static final PointsService instance = PointsService._();

  final _supabase = Supabase.instance.client;

  int _points = 0;
  bool _isLoading = false;

  int get points => _points;
  bool get isLoading => _isLoading;

  /// Charger les points de l'utilisateur connecté
  Future<void> loadPoints() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.rpc('get_user_points');
      _points = response['points'] ?? 0;
    } catch (e) {
      debugPrint('Erreur chargement points: $e');
      // Fallback: lire directement depuis profiles
      try {
        final profile = await _supabase
            .from('profiles')
            .select('points')
            .eq('id', userId)
            .maybeSingle();
        _points = profile?['points'] ?? 0;
      } catch (_) {}
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Ajouter des points après une réservation
  Future<int> addPointsForReservation(int reservationId) async {
    try {
      final response = await _supabase.rpc(
        'add_reservation_points',
        params: {'p_reservation_id': reservationId},
      );

      if (response['success'] == true) {
        final pointsEarned = response['points_earned'] as int;
        _points = response['total_points'] as int;
        notifyListeners();
        return pointsEarned;
      }
    } catch (e) {
      debugPrint('Erreur ajout points: $e');
    }
    return 0;
  }

  /// Réinitialiser les points (déconnexion)
  void reset() {
    _points = 0;
    notifyListeners();
  }
}
