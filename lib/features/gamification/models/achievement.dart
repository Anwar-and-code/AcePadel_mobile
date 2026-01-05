import 'package:flutter/material.dart';

enum AchievementType {
  firstReservation,
  firstMatch,
  welcomeNewbie,
  weeklyStreak,
  monthlyStreak,
  socialButterfly,
  earlyBird,
  nightOwl,
  loyalPlayer,
  champion,
}

class Achievement {
  final AchievementType type;
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int xpReward;
  final String? lottieUrl;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.type,
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.xpReward,
    this.lottieUrl,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      type: type,
      id: id,
      title: title,
      description: description,
      icon: icon,
      color: color,
      xpReward: xpReward,
      lottieUrl: lottieUrl,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

class Achievements {
  static const List<Achievement> all = [
    Achievement(
      type: AchievementType.welcomeNewbie,
      id: 'welcome_newbie',
      title: 'Bienvenue !',
      description: 'Créer votre compte PadelHouse',
      icon: Icons.celebration_rounded,
      color: Color(0xFF6C63FF),
      xpReward: 100,
      lottieUrl: 'https://assets2.lottiefiles.com/packages/lf20_touohxv0.json',
    ),
    Achievement(
      type: AchievementType.firstReservation,
      id: 'first_reservation',
      title: 'Première Réservation',
      description: 'Effectuer votre première réservation',
      icon: Icons.sports_tennis_rounded,
      color: Color(0xFFFF6B6B),
      xpReward: 50,
      lottieUrl: 'https://assets9.lottiefiles.com/packages/lf20_obhph3sh.json',
    ),
    Achievement(
      type: AchievementType.firstMatch,
      id: 'first_match',
      title: 'Premier Match',
      description: 'Jouer votre premier match de padel',
      icon: Icons.emoji_events_rounded,
      color: Color(0xFFFFD93D),
      xpReward: 75,
      lottieUrl: 'https://assets3.lottiefiles.com/packages/lf20_aZTdD5.json',
    ),
    Achievement(
      type: AchievementType.weeklyStreak,
      id: 'weekly_streak',
      title: 'Régulier',
      description: 'Jouer 7 jours consécutifs',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFFF8C00),
      xpReward: 150,
      lottieUrl: 'https://assets5.lottiefiles.com/packages/lf20_xlmz9xwm.json',
    ),
    Achievement(
      type: AchievementType.earlyBird,
      id: 'early_bird',
      title: 'Lève-Tôt',
      description: 'Réserver un créneau avant 9h',
      icon: Icons.wb_sunny_rounded,
      color: Color(0xFF4ECDC4),
      xpReward: 30,
    ),
    Achievement(
      type: AchievementType.nightOwl,
      id: 'night_owl',
      title: 'Noctambule',
      description: 'Réserver un créneau après 21h',
      icon: Icons.nightlight_round,
      color: Color(0xFF9B59B6),
      xpReward: 30,
    ),
    Achievement(
      type: AchievementType.loyalPlayer,
      id: 'loyal_player',
      title: 'Joueur Fidèle',
      description: 'Effectuer 10 réservations',
      icon: Icons.favorite_rounded,
      color: Color(0xFFE91E63),
      xpReward: 200,
    ),
    Achievement(
      type: AchievementType.champion,
      id: 'champion',
      title: 'Champion',
      description: 'Atteindre le niveau 10',
      icon: Icons.military_tech_rounded,
      color: Color(0xFFFFD700),
      xpReward: 500,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  static Achievement? getByType(AchievementType type) {
    try {
      return all.firstWhere((a) => a.type == type);
    } catch (_) {
      return null;
    }
  }
}
