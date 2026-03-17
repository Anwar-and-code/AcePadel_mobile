import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  /// Envoie un code OTP à l'email spécifié via Supabase Auth natif
  /// Utilise le SMTP configuré dans le dashboard Supabase
  static Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email.toLowerCase().trim(),
        shouldCreateUser: true, // Crée l'utilisateur s'il n'existe pas
      );

      return {
        'success': true,
        'message': 'Code envoyé à $email',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'error': 'AUTH_ERROR',
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'NETWORK_ERROR',
        'message': 'Erreur de connexion. Vérifiez votre connexion internet.',
      };
    }
  }

  /// Vérifie le code OTP via Supabase Auth natif
  /// Si le code OTP échoue, tente le code de bypass depuis app_settings
  /// Retourne un Map avec success, is_new_user, session
  static Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    final normalizedEmail = email.toLowerCase().trim();

    // 1. Essayer d'abord la vérification OTP normale
    try {
      final response = await _supabase.auth.verifyOTP(
        email: normalizedEmail,
        token: code,
        type: OtpType.email,
      );

      if (response.session != null) {
        final profile = await getCurrentProfile();
        final isNewUser = profile == null;

        return {
          'success': true,
          'is_new_user': isNewUser,
          'user_id': response.user?.id,
          'session': response.session,
        };
      }
    } catch (_) {
      // OTP normal échoué, on tente le bypass
    }

    // 2. Tenter le bypass via l'Edge Function
    try {
      final bypassResponse = await _supabase.functions.invoke(
        'bypass-otp',
        body: {'email': normalizedEmail, 'code': code},
      );

      if (bypassResponse.status == 200) {
        final data = bypassResponse.data as Map<String, dynamic>;
        final tokenHash = data['token_hash'] as String?;

        if (tokenHash != null) {
          // Vérifier avec le token_hash retourné par l'admin API
          final response = await _supabase.auth.verifyOTP(
            tokenHash: tokenHash,
            type: OtpType.magiclink,
          );

          if (response.session != null) {
            final profile = await getCurrentProfile();
            final isNewUser = profile == null;

            return {
              'success': true,
              'is_new_user': isNewUser,
              'user_id': response.user?.id,
              'session': response.session,
            };
          }
        }
      }

      return {
        'success': false,
        'error': 'INVALID_CODE',
        'message': 'Code invalide ou expiré.',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'error': 'AUTH_ERROR',
        'message': e.message,
      };
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

  /// Crée le profil pour l'utilisateur connecté
  static Future<Map<String, dynamic>> createProfile({
    required String email,
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime birthDate,
    String? phone,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'error': 'NOT_AUTHENTICATED',
          'message': 'Utilisateur non connecté.',
        };
      }

      // Vérifier si le profil existe déjà
      final existingProfile = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfile != null) {
        // Mettre à jour le profil existant
        await _supabase.from('profiles').update({
          'first_name': firstName,
          'last_name': lastName,
          'birth_date': birthDate.toIso8601String().split('T')[0],
          'phone': phone,
          'gender': gender,
        }).eq('id', user.id);
      } else {
        // Créer un nouveau profil
        await _supabase.from('profiles').insert({
          'id': user.id,
          'email': email.toLowerCase().trim(),
          'first_name': firstName,
          'last_name': lastName,
          'birth_date': birthDate.toIso8601String().split('T')[0],
          'phone': phone,
          'gender': gender,
          'role': 'JOUEUR',
        });
      }

      return {
        'success': true,
        'message': 'Profil créé avec succès',
      };
    } on PostgrestException catch (e) {
      return {
        'success': false,
        'error': 'DB_ERROR',
        'message': 'Erreur base de données: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'CREATE_ERROR',
        'message': 'Erreur lors de la création du profil: ${e.toString()}',
      };
    }
  }

  /// Déconnexion
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// URL de callback pour OAuth (deep link)
  static const String _oauthCallbackUrl = 'io.acepadel.app://auth-callback';

  /// Instance Google Sign-In
  static GoogleSignIn? _googleSignIn;

  /// Initialise Google Sign-In (à appeler au démarrage de l'app)
  static Future<void> initializeGoogleSignIn() async {
    if (_googleSignIn != null) return;
    
    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
    final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'];
    
    if (kIsWeb) {
      // Web: utilise uniquement clientId (serverClientId non supporté)
      _googleSignIn = GoogleSignIn(
        clientId: webClientId,
        scopes: ['email', 'profile', 'openid'],
      );
    } else if (Platform.isIOS) {
      // iOS: utilise clientId iOS + serverClientId pour obtenir idToken
      _googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
        scopes: ['email', 'profile', 'openid'],
      );
    } else {
      // Android: utilise serverClientId (Web Client ID) pour obtenir idToken
      // Le SHA-1 du certificat doit être configuré dans Google Cloud Console
      _googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
        scopes: ['email', 'profile', 'openid'],
      );
    }
  }

  /// Connexion avec Google OAuth natif (Google Play Services)
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Initialiser si nécessaire
      await initializeGoogleSignIn();
      
      if (_googleSignIn == null) {
        return {
          'success': false,
          'error': 'CONFIG_ERROR',
          'message': 'Google Sign-In non configuré.',
        };
      }

      // Déconnecter d'abord pour permettre le choix du compte
      await _googleSignIn!.signOut();
      
      // Lancer l'authentification Google native
      final googleUser = await _googleSignIn!.signIn();
      
      if (googleUser == null) {
        return {
          'success': false,
          'error': 'CANCELLED',
          'message': 'Connexion annulée.',
        };
      }

      // Obtenir les tokens
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        return {
          'success': false,
          'error': 'TOKEN_ERROR',
          'message': 'Impossible d\'obtenir le token Google.',
        };
      }

      // Authentifier avec Supabase via le token Google
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.session != null) {
        return {
          'success': true,
          'message': 'Connexion Google réussie',
          'user_id': response.user?.id,
        };
      } else {
        return {
          'success': false,
          'error': 'AUTH_ERROR',
          'message': 'Échec de l\'authentification Supabase.',
        };
      }
    } on AuthException catch (e) {
      return {
        'success': false,
        'error': 'AUTH_ERROR',
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'NETWORK_ERROR',
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  /// Connexion avec Microsoft OAuth (Azure AD)
  static Future<Map<String, dynamic>> signInWithMicrosoft() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.azure,
        redirectTo: kIsWeb ? null : _oauthCallbackUrl,
        scopes: 'email profile openid',
      );

      if (response) {
        return {
          'success': true,
          'message': 'Redirection vers Microsoft...',
        };
      } else {
        return {
          'success': false,
          'error': 'OAUTH_ERROR',
          'message': 'Impossible de démarrer l\'authentification Microsoft.',
        };
      }
    } on AuthException catch (e) {
      return {
        'success': false,
        'error': 'AUTH_ERROR',
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'NETWORK_ERROR',
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  /// Écoute les changements d'état d'authentification
  static Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

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
