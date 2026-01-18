import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/achievement.dart';
import '../models/gamification_event.dart';

/// Modèle pour le profil de gamification complet depuis Supabase
class GamificationProfile {
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final int totalReservations;
  final String? levelTitle;
  final String? badgeColor;
  final double levelProgress;
  final int xpForNext;
  final List<UnlockedAchievement> achievements;
  final List<AvailableAchievement> availableAchievements;

  GamificationProfile({
    required this.xp,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalReservations,
    this.levelTitle,
    this.badgeColor,
    required this.levelProgress,
    required this.xpForNext,
    required this.achievements,
    required this.availableAchievements,
  });

  factory GamificationProfile.fromJson(Map<String, dynamic> json) {
    final levelInfo = json['level_info'] as Map<String, dynamic>? ?? {};
    
    return GamificationProfile(
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      totalReservations: json['total_reservations'] ?? 0,
      levelTitle: levelInfo['title'],
      badgeColor: levelInfo['badge_color'],
      levelProgress: (levelInfo['progress'] ?? 0.0).toDouble(),
      xpForNext: levelInfo['xp_for_next'] ?? 100,
      achievements: (json['achievements'] as List? ?? [])
          .map((a) => UnlockedAchievement.fromJson(a))
          .toList(),
      availableAchievements: (json['available_achievements'] as List? ?? [])
          .map((a) => AvailableAchievement.fromJson(a))
          .toList(),
    );
  }

  factory GamificationProfile.empty() => GamificationProfile(
    xp: 0,
    level: 1,
    currentStreak: 0,
    longestStreak: 0,
    totalReservations: 0,
    levelProgress: 0,
    xpForNext: 100,
    achievements: [],
    availableAchievements: [],
  );
}

class UnlockedAchievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String color;
  final int xpReward;
  final DateTime unlockedAt;

  UnlockedAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.xpReward,
    required this.unlockedAt,
  });

  factory UnlockedAchievement.fromJson(Map<String, dynamic> json) {
    return UnlockedAchievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      color: json['color'] ?? '#FFD700',
      xpReward: json['xp_reward'] ?? 0,
      unlockedAt: DateTime.tryParse(json['unlocked_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class AvailableAchievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String category;
  final int xpReward;

  AvailableAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.xpReward,
  });

  factory AvailableAchievement.fromJson(Map<String, dynamic> json) {
    return AvailableAchievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      category: json['category'] ?? 'general',
      xpReward: json['xp_reward'] ?? 0,
    );
  }
}

class LeaderboardEntry {
  final String oderId;
  final String? fullName;
  final String? avatarUrl;
  final int xp;
  final int level;
  final int currentStreak;
  final int rank;

  LeaderboardEntry({
    required this.oderId,
    this.fullName,
    this.avatarUrl,
    required this.xp,
    required this.level,
    required this.currentStreak,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      oderId: json['user_id'] ?? '',
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      currentStreak: json['current_streak'] ?? 0,
      rank: json['rank'] ?? 0,
    );
  }
}

/// Service de gamification - Client Supabase
/// Toute la logique est côté serveur via les fonctions RPC
class GamificationServiceV2 extends ChangeNotifier {
  static final GamificationServiceV2 instance = GamificationServiceV2._();
  
  GamificationServiceV2._() {
    _init();
  }

  static SupabaseClient get _supabase => Supabase.instance.client;

  // Stream controller for gamification events (UI animations)
  final _eventController = StreamController<GamificationEvent>.broadcast();
  Stream<GamificationEvent> get events => _eventController.stream;

  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  GamificationProfile _profile = GamificationProfile.empty();
  GamificationProfile get profile => _profile;

  // Getters pour compatibilité avec l'UI existante
  int get xp => _profile.xp;
  int get level => _profile.level;
  int get currentStreak => _profile.currentStreak;
  int get longestStreak => _profile.longestStreak;
  int get reservationsCount => _profile.totalReservations;
  double get currentLevelProgress => _profile.levelProgress;
  int get xpToNextLevel => _profile.xpForNext - _profile.xp;
  String? get levelTitle => _profile.levelTitle;
  
  Set<String> get unlockedAchievements => 
      _profile.achievements.map((a) => a.id).toSet();

  bool isAchievementUnlocked(String achievementId) {
    return _profile.achievements.any((a) => a.id == achievementId);
  }

  Future<void> _init() async {
    // Load from cache first for instant display
    await _loadFromCache();
    
    // Then sync with Supabase
    if (_supabase.auth.currentUser != null) {
      await reload();
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedXp = prefs.getInt('gamification_xp') ?? 0;
      final cachedStreak = prefs.getInt('gamification_streak') ?? 0;
      final cachedLevel = prefs.getInt('gamification_level') ?? 1;
      
      _profile = GamificationProfile(
        xp: cachedXp,
        level: cachedLevel,
        currentStreak: cachedStreak,
        longestStreak: prefs.getInt('gamification_longest_streak') ?? 0,
        totalReservations: prefs.getInt('gamification_reservations') ?? 0,
        levelProgress: 0,
        xpForNext: 100,
        achievements: [],
        availableAchievements: [],
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading from cache: $e');
    }
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('gamification_xp', _profile.xp);
      await prefs.setInt('gamification_level', _profile.level);
      await prefs.setInt('gamification_streak', _profile.currentStreak);
      await prefs.setInt('gamification_longest_streak', _profile.longestStreak);
      await prefs.setInt('gamification_reservations', _profile.totalReservations);
    } catch (e) {
      debugPrint('Error saving to cache: $e');
    }
  }

  /// Recharge le profil complet depuis Supabase
  Future<void> reload() async {
    if (_supabase.auth.currentUser == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.rpc('get_gamification_profile');
      
      if (response != null) {
        _profile = GamificationProfile.fromJson(response as Map<String, dynamic>);
        await _saveToCache();
      }
    } catch (e) {
      debugPrint('Error loading gamification profile: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Appelé après une réservation réussie - toute la logique est côté Supabase
  Future<void> onReservationMade({int? hour}) async {
    if (_supabase.auth.currentUser == null) return;

    try {
      final oldLevel = _profile.level;
      
      final response = await _supabase.rpc(
        'on_reservation_completed',
        params: {'p_reservation_hour': hour},
      );

      if (response != null) {
        final result = response as Map<String, dynamic>;
        final xpEarned = result['xp_earned'] as int? ?? 50;
        final achievementsUnlocked = (result['achievements_unlocked'] as List?)?.cast<String>() ?? [];
        
        // Emit XP event for UI animation
        _eventController.add(GamificationEvent.xpEarned(xpEarned, message: 'Réservation confirmée'));
        
        // Reload profile to get updated data
        await reload();
        
        // Check for level up
        if (_profile.level > oldLevel) {
          _eventController.add(GamificationEvent.levelUp(_profile.level));
        }
        
        // Emit achievement events
        for (final achievementId in achievementsUnlocked) {
          final achievement = _profile.achievements.firstWhere(
            (a) => a.id == achievementId,
            orElse: () => UnlockedAchievement(
              id: achievementId,
              title: 'Achievement',
              description: '',
              icon: '🏆',
              color: '#FFD700',
              xpReward: 0,
              unlockedAt: DateTime.now(),
            ),
          );
          
          _eventController.add(GamificationEvent.achievementUnlocked(
            Achievement(
              id: achievement.id,
              type: AchievementType.values.firstWhere(
                (t) => t.name == achievement.id.replaceAll('_', ''),
                orElse: () => AchievementType.welcomeNewbie,
              ),
              title: achievement.title,
              description: achievement.description,
              icon: _iconFromEmoji(achievement.icon),
              color: _colorFromHex(achievement.color),
              xpReward: achievement.xpReward,
            ),
          ));
        }
      }
    } catch (e) {
      debugPrint('Error on reservation gamification: $e');
      // Fallback: just reload
      await reload();
    }
  }

  /// Obtenir le leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 10}) async {
    try {
      final response = await _supabase.rpc(
        'get_leaderboard',
        params: {'p_limit': limit},
      );
      
      if (response != null) {
        return (response as List)
            .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error getting leaderboard: $e');
    }
    return [];
  }

  /// Obtenir l'historique des événements
  Future<List<Map<String, dynamic>>> getHistory({int limit = 20}) async {
    try {
      final response = await _supabase.rpc(
        'get_gamification_history',
        params: {'p_limit': limit},
      );
      
      if (response != null) {
        return (response as List).cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Error getting history: $e');
    }
    return [];
  }

  // Helper methods
  IconData _iconFromEmoji(String emoji) {
    switch (emoji) {
      case '🎉': return Icons.celebration;
      case '🎾': return Icons.sports_tennis;
      case '🏆': return Icons.emoji_events;
      case '🔥': return Icons.local_fire_department;
      case '💪': return Icons.fitness_center;
      case '☀️': return Icons.wb_sunny;
      case '🌙': return Icons.nightlight_round;
      case '❤️': return Icons.favorite;
      case '🤩': return Icons.star;
      case '🏅': return Icons.military_tech;
      case '👑': return Icons.workspace_premium;
      case '💯': return Icons.looks_one;
      default: return Icons.emoji_events;
    }
  }

  Color _colorFromHex(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFFFFD700);
    }
  }

  // Legacy methods for compatibility
  Future<void> awardXp(int amount, {String? message}) async {
    // Now handled by Supabase RPC
    _eventController.add(GamificationEvent.xpEarned(amount, message: message));
    await reload();
  }

  Future<void> unlockAchievement(AchievementType type) async {
    // Now handled automatically by Supabase
    await reload();
  }

  Future<void> onAccountCreated() async {
    // Handled by Supabase trigger on profile creation
    await reload();
  }

  Future<void> onMatchCompleted() async {
    // TODO: Implement match completion RPC if needed
    await reload();
  }

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gamification_xp');
    await prefs.remove('gamification_level');
    await prefs.remove('gamification_streak');
    await prefs.remove('gamification_longest_streak');
    await prefs.remove('gamification_reservations');
    
    _profile = GamificationProfile.empty();
    notifyListeners();
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
