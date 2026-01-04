import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

class ReplaysScreen extends StatelessWidget {
  const ReplaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Replays'),
      ),
      body: AppEmptyState(
        title: 'Aucun Replay',
        message: 'Vos vidéos de matchs apparaîtront ici.\nJouez votre premier match filmé !',
        // Using a standard Lottie JSON URL for "video empty state" 
        // In a real app, this would be a local asset or a specific branded URL.
        lottieUrl: 'https://lottie.host/95191986-5387-430c-ab9a-2735775aa705/1e1e1e1e1e.json', 
        actionLabel: 'Réserver un terrain',
        onAction: () {
          // Go back to home to book
          Navigator.of(context).pop(); 
          // Ideally switch specific tab, but pop is safe default
        },
      ),
    );
  }
}
