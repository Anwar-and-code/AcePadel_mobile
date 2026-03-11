import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/design_system/design_system.dart';
import 'core/services/push_notification_service.dart';
import 'app/app_router.dart';
import 'features/reservation/providers/reservation_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  // Initialiser Firebase (mobile uniquement)
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      debugPrint('[Firebase] Init error: $e');
    }
  }

  await Supabase.initialize(url: dotenv.env['SUPABASE_URL']!, anonKey: dotenv.env['SUPABASE_ANON_KEY']!);

  // Initialiser les Push Notifications (mobile uniquement)
  if (!kIsWeb && !Platform.isIOS) {
    await PushNotificationService().initialize(
      onTap: (data) {
        // Naviguer selon le type de notification
        if (data.containsKey('reservation_id')) {
          // Navigation vers la réservation
        } else if (data.containsKey('event_id')) {
          // Navigation vers l'événement
        }
      },
    );
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const PadelHouseApp());
}

class PadelHouseApp extends StatelessWidget {
  const PadelHouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReservationProvider(),
      child: MaterialApp(
        title: 'PadelHouse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
