import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  /// Envoie un code OTP à l'email spécifié
  /// Retourne un Map avec success, message, et éventuellement debug_code (dev only)
  static Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-otp-email',
        body: {'email': email.toLowerCase().trim()},
      );

      if (response.status != 200) {
        return {
          'success': false,
          'error': 'SERVER_ERROR',
          'message': 'Erreur serveur. Veuillez réessayer.',
        };
      }

      final data = response.data as Map<String, dynamic>;
      return data;
    } catch (e) {
      return {
        'success': false,
        'error': 'NETWORK_ERROR',
        'message': 'Erreur de connexion. Vérifiez votre connexion internet.',
      };
    }
  }

  /// Vérifie le code OTP
  /// Retourne un Map avec success, is_new_user, user_id, ou error/message
  static Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    try {
      final response = await _supabase.rpc(
        'verify_otp',
        params: {
          'p_email': email.toLowerCase().trim(),
          'p_code': code,
        },
      );

      final data = response as Map<String, dynamic>;
      return data;
    } catch (e) {
      return {
        'success': false,
        'error': 'NETWORK_ERROR',
        'message': 'Erreur de connexion. Vérifiez votre connexion internet.',
      };
    }
  }

  /// Crée un nouvel utilisateur avec les informations du profil
  static Future<Map<String, dynamic>> createUser({
    required String email,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    required String gender,
    String? phone,
  }) async {
    try {
      // Utiliser signUp avec email et un mot de passe généré
      // L'utilisateur se connectera toujours via OTP
      final password = _generateSecurePassword();
      
      final authResponse = await _supabase.auth.signUp(
        email: email.toLowerCase().trim(),
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      if (authResponse.user == null) {
        return {
          'success': false,
          'error': 'AUTH_ERROR',
          'message': 'Erreur lors de la création du compte.',
        };
      }

      // Créer le profil
      await _supabase.from('profiles').insert({
        'id': authResponse.user!.id,
        'email': email.toLowerCase().trim(),
        'first_name': firstName,
        'last_name': lastName,
        'birth_date': birthDate.toIso8601String().split('T')[0],
        'gender': gender,
        'role': 'JOUEUR',
      });

      return {
        'success': true,
        'user_id': authResponse.user!.id,
        'message': 'Compte créé avec succès',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'CREATE_ERROR',
        'message': 'Erreur lors de la création du compte: ${e.toString()}',
      };
    }
  }

  /// Connecte un utilisateur existant via magic link après vérification OTP
  static Future<Map<String, dynamic>> signInWithOtp(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email.toLowerCase().trim(),
        shouldCreateUser: false,
      );

      return {
        'success': true,
        'message': 'Connexion réussie',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'SIGNIN_ERROR',
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  /// Vérifie si un profil existe pour l'utilisateur connecté
  static Future<Map<String, dynamic>?> getCurrentProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Vérifie si un utilisateur existe par email
  static Future<bool> userExists(String email) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id')
          .eq('email', email.toLowerCase().trim())
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Déconnexion
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Génère un mot de passe sécurisé aléatoire
  static String _generateSecurePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(32, (index) => chars[(random + index * 7) % chars.length]).join();
  }

  /// Getter pour l'utilisateur courant
  static User? get currentUser => _supabase.auth.currentUser;

  /// Getter pour le client Supabase
  static SupabaseClient get client => _supabase;
}
