import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service singleton pour les paramètres de l'application (app_settings)
class AppSettingsService extends ChangeNotifier {
  AppSettingsService._();
  static final AppSettingsService instance = AppSettingsService._();

  static SupabaseClient get _supabase => Supabase.instance.client;

  String? _businessNumber;
  String? _businessName;
  String? _businessPhone;
  String? _businessEmail;
  String? _businessAddress;
  bool _isLoading = false;
  bool _isLoaded = false;

  /// Numéro complet avec indicatif (+2250XXXXXXXXX)
  String? get businessNumber => _businessNumber;

  /// Nom de l'entreprise
  String? get businessName => _businessName;

  /// Téléphone formaté pour affichage (ex: 07 05 40 94 15)
  String? get businessPhone => _businessPhone;

  /// Email
  String? get businessEmail => _businessEmail;

  /// Adresse
  String? get businessAddress => _businessAddress;

  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;

  /// Numéro local normalisé (0XXXXXXXXX)
  String get _localNumber {
    final raw = _businessNumber ?? '';
    if (raw.startsWith('+225')) return raw.substring(4);
    if (raw.startsWith('225') && raw.length > 10) return raw.substring(3);
    return raw;
  }

  /// Numéro pour les appels tel: (format international +225XXXXXXXXXX)
  String get callNumber => '+225${_localNumber}';

  /// Numéro pour WhatsApp (sans le +) : 225XXXXXXXXXX
  String get whatsappNumber => '225${_localNumber}';

  /// Numéro formaté pour affichage (ex: +225 07 05 40 94 15)
  String get displayNumber {
    final local = _localNumber;
    if (local.isEmpty) return _businessPhone ?? '';
    final buffer = StringBuffer('+225 ');
    for (int i = 0; i < local.length; i++) {
      buffer.write(local[i]);
      if ((i + 1) % 2 == 0 && i < local.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  /// Charge les paramètres depuis la table app_settings
  Future<void> loadSettings() async {
    if (_isLoaded) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('app_settings')
          .select('business_name, business_phone, business_email, business_address, business_number')
          .limit(1)
          .maybeSingle();

      if (response != null) {
        _businessName = response['business_name'] as String?;
        _businessPhone = response['business_phone'] as String?;
        _businessEmail = response['business_email'] as String?;
        _businessAddress = response['business_address'] as String?;
        _businessNumber = response['business_number'] as String?;
        _isLoaded = true;
      }
    } catch (e) {
      debugPrint('Erreur chargement app_settings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Force le rechargement des paramètres
  Future<void> reload() async {
    _isLoaded = false;
    await loadSettings();
  }

  /// Réinitialise le service
  void reset() {
    _businessNumber = null;
    _businessName = null;
    _businessPhone = null;
    _businessEmail = null;
    _businessAddress = null;
    _isLoaded = false;
    _isLoading = false;
    notifyListeners();
  }
}
