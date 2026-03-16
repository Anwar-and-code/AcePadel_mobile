import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../firebase_options.dart';

// Handler pour les messages en background (doit être top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[FCM Notification] background received');
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();

  factory PushNotificationService() => _instance;

  PushNotificationService._internal();

  FirebaseMessaging? _messagingInstance;

  FirebaseMessaging get _messaging {
    _messagingInstance ??= FirebaseMessaging.instance;
    return _messagingInstance!;
  }

  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Callback pour naviguer quand on tap une notification
  Function(Map<String, dynamic> data)? onNotificationTap;

  /// Appeler une seule fois au démarrage de l'app (après Firebase.initializeApp)
  Future<void> initialize({Function(Map<String, dynamic> data)? onTap}) async {
    if (_initialized) return;
    if (kIsWeb) return; // Firebase Messaging not supported on web
    _initialized = true;
    onNotificationTap = onTap;

    // Enregistrer le handler background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Configurer les notifications locales (pour afficher en foreground)
    await _setupLocalNotifications();

    // Demander la permission
    // final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true, provisional: false);
    final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true, provisional: false);

    await _messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Récupérer et sauvegarder le token FCM
      final token = await _getToken();
      if (token != null) {
        await _saveTokenToSupabase(token);
      }

      // Écouter les changements de token (rotation automatique)
      _messaging.onTokenRefresh.listen(_saveTokenToSupabase);
    }

    // --- Écouter les notifications ---

    // 1. App en FOREGROUND → afficher une notification locale
    // FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 2. App en BACKGROUND → tap sur la notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 3. App TERMINÉE → vérifier si lancée via une notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Configurer flutter_local_notifications
  Future<void> _setupLocalNotifications() async {
    const androidChannel = AndroidNotificationChannel(
      'padelhouse_notifications',
      'PadelHouse Notifications',
      description: 'Notifications de PadelHouse',
      importance: Importance.high,
    );

    // Créer le channel Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    const initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: initAndroid, iOS: initIOS),
      onDidReceiveNotificationResponse: (response) {
        // Quand l'utilisateur tap la notification locale
        if (response.payload != null) {
          // Parse le payload si nécessaire
        }
      },
    );
  }

  /// Afficher la notification quand l'app est au premier plan
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM Notification] foreground received');

    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'padelhouse_notifications',
          'PadelHouse Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      ),
    );
  }

  /// Naviguer quand l'utilisateur tap une notification
  void _handleNotificationTap(RemoteMessage message) {
    if (onNotificationTap != null) {
      onNotificationTap!(message.data);
    }
  }

  /// Sauvegarder le token FCM dans Supabase
  Future<void> _saveTokenToSupabase(String token) async {
    debugPrint('[FCM Token] $token');
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Supabase.instance.client.from('fcm_tokens').upsert({
        'user_id': userId,
        'token': token,
        'device_type': Platform.isIOS ? 'ios' : 'android',
        'device_name': '${Platform.isIOS ? 'iPhone' : 'Android'}',
        'is_active': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id,token');
      print('[FCM] Token saved to Supabase');
    } catch (e) {
      print('[FCM] Error saving token: $e');
    }
  }

  /// Appeler après la connexion de l'utilisateur pour enregistrer/réenregistrer le token
  Future<void> registerAfterLogin() async {
    if (kIsWeb) return;
    try {
      final token = await _getToken();
      if (token != null) {
        await _saveTokenToSupabase(token);
      }
    } catch (e) {
      print('[FCM] Error registering after login: $e');
    }
  }

  /// Appeler à la déconnexion pour désactiver le token
  Future<void> unregisterOnLogout() async {
    if (kIsWeb) return;
    try {
      final token = await _getToken();
      if (token != null) {
        await Supabase.instance.client
            .from('fcm_tokens')
            .update({'is_active': false, 'updated_at': DateTime.now().toUtc().toIso8601String()})
            .eq('token', token);
        print('[FCM] Token deactivated');
      }
    } catch (e) {
      print('[FCM] Error deactivating token: $e');
    }
  }

  Future<String?> _getToken() async {
    try {
      // iOS requires APNS token first
      if (Platform.isIOS) {
        String? apnsToken = await _messaging.getAPNSToken();

        int retry = 0;
        while (apnsToken == null && retry < 10) {
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await _messaging.getAPNSToken();
          retry++;
        }
        print('[FCM] APNS Token: $apnsToken');
      }

      final fcmToken = await _messaging.getToken();
      return fcmToken;
    } catch (e) {
      print('[FCM] Error getting token: $e');
      return null;
    }
  }
}
