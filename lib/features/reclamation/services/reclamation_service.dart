import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reclamation.dart';

/// Service pour gérer les réclamations utilisateur
class ReclamationService extends ChangeNotifier {
  static final ReclamationService instance = ReclamationService._();
  ReclamationService._();

  static SupabaseClient get _supabase => Supabase.instance.client;

  List<Reclamation> _reclamations = [];
  bool _isLoading = false;
  String? _error;

  List<Reclamation> get reclamations => _reclamations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge les réclamations de l'utilisateur connecté
  Future<void> loadReclamations() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('reclamations')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      _reclamations = (response as List)
          .map((json) => Reclamation.fromJson(json))
          .toList();
    } catch (e) {
      _error = 'Erreur lors du chargement des réclamations';
      debugPrint('Error loading reclamations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Crée une nouvelle réclamation avec upload de photos optionnel
  Future<Map<String, dynamic>> createReclamation({
    required String subject,
    required String description,
    required ReclamationCategory category,
    List<Uint8List>? photoBytes,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Utilisateur non connecté'};
    }

    try {
      List<String> photoUrls = [];

      // Upload des photos si présentes
      if (photoBytes != null && photoBytes.isNotEmpty) {
        for (int i = 0; i < photoBytes.length; i++) {
          final bytes = photoBytes[i];
          final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          
          await _supabase.storage
              .from('reclamations')
              .uploadBinary(fileName, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));

          // Générer l'URL signée (valide 1 an)
          final signedUrl = await _supabase.storage
              .from('reclamations')
              .createSignedUrl(fileName, 31536000);
          
          photoUrls.add(signedUrl);
        }
      }

      // Créer la réclamation
      final response = await _supabase.from('reclamations').insert({
        'user_id': user.id,
        'subject': subject,
        'description': description,
        'category': category.value,
        'photo_urls': photoUrls,
      }).select().single();

      final newReclamation = Reclamation.fromJson(response);
      _reclamations.insert(0, newReclamation);
      notifyListeners();

      return {'success': true, 'reclamation': newReclamation};
    } on StorageException catch (e) {
      return {'success': false, 'message': 'Erreur upload photo: ${e.message}'};
    } on PostgrestException catch (e) {
      return {'success': false, 'message': 'Erreur base de données: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: ${e.toString()}'};
    }
  }

  /// Met à jour une réclamation existante
  Future<Map<String, dynamic>> updateReclamation({
    required String id,
    String? subject,
    String? description,
    ReclamationCategory? category,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (subject != null) updates['subject'] = subject;
      if (description != null) updates['description'] = description;
      if (category != null) updates['category'] = category.value;

      final response = await _supabase
          .from('reclamations')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      final updatedReclamation = Reclamation.fromJson(response);
      final index = _reclamations.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reclamations[index] = updatedReclamation;
        notifyListeners();
      }

      return {'success': true, 'reclamation': updatedReclamation};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: ${e.toString()}'};
    }
  }

  /// Récupère une réclamation par son ID
  Reclamation? getReclamationById(String id) {
    try {
      return _reclamations.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Compte les réclamations par statut
  int countByStatus(ReclamationStatus status) {
    return _reclamations.where((r) => r.status == status).length;
  }

  /// Réinitialise le service
  void reset() {
    _reclamations = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
