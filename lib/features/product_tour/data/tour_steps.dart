import 'package:flutter/material.dart';

/// Represents a single step in the product tour
class TourStep {
  final String id;
  final String title;
  final String description;
  final IconData? icon;

  const TourStep({
    required this.id,
    required this.title,
    required this.description,
    this.icon,
  });
}

/// All tour steps with French content
class TourSteps {
  TourSteps._();

  static const welcome = TourStep(
    id: 'welcome',
    title: 'Bienvenue sur AcePadel! 🎾',
    description: 'Naviguez entre les sections principales de l\'app grâce à la barre de navigation.',
    icon: Icons.waving_hand,
  );

  static const banner = TourStep(
    id: 'banner',
    title: 'Découvrez les actualités',
    description: 'Restez informé des dernières offres, promotions et événements exclusifs.',
    icon: Icons.campaign_outlined,
  );

  static const actionCards = TourStep(
    id: 'action_cards',
    title: 'Réservez facilement',
    description: 'Accédez rapidement à vos courts favoris et aux services disponibles.',
    icon: Icons.sports_tennis,
  );

  static const profile = TourStep(
    id: 'profile',
    title: 'Suivez votre progression',
    description: 'Consultez votre profil, vos statistiques et votre niveau de joueur.',
    icon: Icons.person_outline,
  );

  static const dateSelector = TourStep(
    id: 'date_selector',
    title: 'Choisissez votre date',
    description: 'Sélectionnez le jour idéal pour votre prochaine session de padel.',
    icon: Icons.calendar_today,
  );

  static const courtSelector = TourStep(
    id: 'court_selector',
    title: 'Sélectionnez un court',
    description: 'Choisissez parmi nos courts disponibles et consultez leurs caractéristiques.',
    icon: Icons.grid_view,
  );

  static const events = TourStep(
    id: 'events',
    title: 'Participez aux événements',
    description: 'Inscrivez-vous aux tournois, compétitions et événements communautaires.',
    icon: Icons.emoji_events_outlined,
  );

  /// Get all steps in order
  static List<TourStep> get allSteps => [
        welcome,
        banner,
        actionCards,
        profile,
        dateSelector,
        courtSelector,
        events,
      ];

  /// Total number of steps
  static int get stepCount => allSteps.length;
}
