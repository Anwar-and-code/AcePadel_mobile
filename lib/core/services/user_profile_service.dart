import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modèle pour le profil utilisateur
class UserProfile {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatarUrl;
  final String? gender;
  final DateTime? birthDate;
  final String role;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatarUrl,
    this.gender,
    this.birthDate,
    required this.role,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      gender: json['gender'],
      birthDate: json['birth_date'] != null 
          ? DateTime.tryParse(json['birth_date']) 
          : null,
      role: json['role'] ?? 'JOUEUR',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  /// Nom complet
  String get fullName {
    if (firstName == null && lastName == null) return 'Utilisateur';
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  /// Prénom seul
  String get displayName => firstName ?? 'Utilisateur';

  /// Initiales pour l'avatar
  String get initials {
    final first = firstName?.isNotEmpty == true ? firstName![0].toUpperCase() : '';
    final last = lastName?.isNotEmpty == true ? lastName![0].toUpperCase() : '';
    if (first.isEmpty && last.isEmpty) return 'U';
    return '$first$last';
  }

  /// Vérifie si l'utilisateur a une photo de profil
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
}

/// Service pour gérer le profil utilisateur
class UserProfileService extends ChangeNotifier {
  static final UserProfileService instance = UserProfileService._();
  
  UserProfileService._();

  static SupabaseClient get _supabase => Supabase.instance.client;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  /// Charge le profil de l'utilisateur connecté
  Future<UserProfile?> loadProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _profile = null;
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        _profile = UserProfile.fromJson(response);
      } else {
        // Créer un profil minimal si inexistant
        _profile = UserProfile(
          id: user.id,
          email: user.email ?? '',
          role: 'JOUEUR',
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      _error = 'Erreur lors du chargement du profil';
      debugPrint('Error loading profile: $e');
    }

    _isLoading = false;
    notifyListeners();
    return _profile;
  }

  /// Met à jour le profil
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? gender,
    DateTime? birthDate,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updates = <String, dynamic>{};
      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (phone != null) updates['phone'] = phone;
      if (gender != null) updates['gender'] = gender;
      if (birthDate != null) {
        updates['birth_date'] = birthDate.toIso8601String().split('T')[0];
      }

      if (updates.isNotEmpty) {
        await _supabase
            .from('profiles')
            .update(updates)
            .eq('id', user.id);
        
        // Recharger le profil
        await loadProfile();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour du profil';
      debugPrint('Error updating profile: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Upload une photo de profil vers Supabase Storage
  Future<String?> uploadAvatar(File imageFile) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final fileExt = imageFile.path.split('.').last.toLowerCase();
      final fileName = '${user.id}/avatar.$fileExt';
      
      // Upload vers le bucket 'avatars'
      await _supabase.storage
          .from('avatars')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // Obtenir l'URL publique
      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Mettre à jour le profil avec l'URL
      await _supabase
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', user.id);

      // Recharger le profil
      await loadProfile();

      return publicUrl;
    } catch (e) {
      _error = 'Erreur lors de l\'upload de la photo';
      debugPrint('Error uploading avatar: $e');
      return null;
    }
  }

  /// Supprime la photo de profil
  Future<bool> removeAvatar() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    try {
      // Supprimer du storage
      final files = await _supabase.storage
          .from('avatars')
          .list(path: user.id);
      
      for (final file in files) {
        await _supabase.storage
            .from('avatars')
            .remove(['${user.id}/${file.name}']);
      }

      // Mettre à jour le profil
      await _supabase
          .from('profiles')
          .update({'avatar_url': null})
          .eq('id', user.id);

      await loadProfile();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression de la photo';
      debugPrint('Error removing avatar: $e');
      return false;
    }
  }

  /// Réinitialise le service (à appeler lors de la déconnexion)
  void reset() {
    _profile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
