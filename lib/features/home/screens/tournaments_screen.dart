import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournois'),
      ),
      body: AppEmptyState(
        title: 'Bientôt disponible !',
        message: 'Les tournois arrivent très prochainement sur PadelHouse.\nPréparez votre équipe !',
        // Example Lottie URL for "trophy/tournament"
        lottieUrl: 'https://lottie.host/95191986-5387-430c-ab9a-2735775aa705/1e1e1e1e1e.json',
        actionLabel: 'Retour à l\'accueil',
        onAction: () => Navigator.of(context).pop(),
      ),
    );
  }
}
