import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/gamification_event.dart';

class GamificationServiceV2 extends ChangeNotifier {
  static final GamificationServiceV2 instance = GamificationServiceV2._();
  
  GamificationServiceV2._() {
    _loadProgress();
  }

  // Stream controller for gamification events
  final _eventController = StreamController<GamificationEvent>.broadcast();
  Stream<GamificationEvent> get events => _eventController.stream;

  // XP and Level
  int _xp = 0;
  int get xp => _xp;
  int get level => (_xp / 200).floor() + 1; // 200 XP per level
  
  double get currentLevelProgress {
    final int xpForCurrentLevel = (level - 1) * 200;
    final int xpForNextLevel = level * 200;
    return (_xp - xpForCurrentLevel) / (xpForNextLevel - xpForCurrentLevel);
  }
  
  int get xpToNextLevel {
    final int xpForNextLevel = level * 200;
    return xpForNextLevel - _xp;
  }

  // Streak
  int _currentStreak = 0;
  int get currentStreak => _currentStreak;
  DateTime? _lastActivityDate;

  // Reservations count
  int _reservationsCount = 0;
  int get reservationsCount => _reservationsCount;

  // Unlocked achievements
  final Set<String> _unlockedAchievements = {};
  Set<String> get unlockedAchievements => Set.unmodifiable(_unlockedAchievements);

  bool isAchievementUnlocked(String achievementId) {
    return _unlockedAchievements.contains(achievementId);
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _xp = prefs.getInt('gamification_xp') ?? 0;
    _currentStreak = prefs.getInt('gamification_streak') ?? 0;
    _reservationsCount = prefs.getInt('gamification_reservations') ?? 0;
    
    final lastActivityStr = prefs.getString('gamification_last_activity');
    if (lastActivityStr != null) {
      _lastActivityDate = DateTime.tryParse(lastActivityStr);
    }
    
    final unlockedList = prefs.getStringList('gamification_achievements') ?? [];
    _unlockedAchievements.addAll(unlockedList);
    
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gamification_xp', _xp);
    await prefs.setInt('gamification_streak', _currentStreak);
    await prefs.setInt('gamification_reservations', _reservationsCount);
    if (_lastActivityDate != null) {
      await prefs.setString('gamification_last_activity', _lastActivityDate!.toIso8601String());
    }
    await prefs.setStringList('gamification_achievements', _unlockedAchievements.toList());
  }

  /// Award XP and check for level up
  Future<void> awardXp(int amount, {String? message}) async {
    final oldLevel = level;
    _xp += amount;
    await _saveProgress();
    notifyListeners();

    // Emit XP earned event
    _eventController.add(GamificationEvent.xpEarned(amount, message: message));

    // Check for level up
    if (level > oldLevel) {
      _eventController.add(GamificationEvent.levelUp(level));
      
      // Check for champion achievement at level 10
      if (level >= 10) {
        await unlockAchievement(AchievementType.champion);
      }
    }
  }

  /// Unlock an achievement
  Future<void> unlockAchievement(AchievementType type) async {
    final achievement = Achievements.getByType(type);
    if (achievement == null) return;
    
    if (_unlockedAchievements.contains(achievement.id)) return;
    
    _unlockedAchievements.add(achievement.id);
    _xp += achievement.xpReward;
    await _saveProgress();
    notifyListeners();

    // Emit achievement unlocked event
    _eventController.add(GamificationEvent.achievementUnlocked(achievement));
  }

  /// Update activity streak
  Future<void> updateStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastActivityDate != null) {
      final lastDate = DateTime(
        _lastActivityDate!.year,
        _lastActivityDate!.month,
        _lastActivityDate!.day,
      );
      
      final difference = today.difference(lastDate).inDays;
      
      if (difference == 1) {
        // Consecutive day
        _currentStreak++;
      } else if (difference > 1) {
        // Streak broken
        _currentStreak = 1;
      }
      // Same day - no change
    } else {
      _currentStreak = 1;
    }
    
    _lastActivityDate = now;
    await _saveProgress();
    notifyListeners();

    _eventController.add(GamificationEvent.streakUpdated(_currentStreak));

    // Check for streak achievements
    if (_currentStreak >= 7 && !isAchievementUnlocked('weekly_streak')) {
      await unlockAchievement(AchievementType.weeklyStreak);
    }
  }

  /// Called when user creates account
  Future<void> onAccountCreated() async {
    await unlockAchievement(AchievementType.welcomeNewbie);
  }

  /// Called when user makes a reservation
  Future<void> onReservationMade({int? hour}) async {
    _reservationsCount++;
    await _saveProgress();
    await updateStreak();
    
    // First reservation achievement
    if (_reservationsCount == 1) {
      await unlockAchievement(AchievementType.firstReservation);
    }
    
    // Loyal player achievement
    if (_reservationsCount >= 10 && !isAchievementUnlocked('loyal_player')) {
      await unlockAchievement(AchievementType.loyalPlayer);
    }
    
    // Time-based achievements
    if (hour != null) {
      if (hour < 9 && !isAchievementUnlocked('early_bird')) {
        await unlockAchievement(AchievementType.earlyBird);
      }
      if (hour >= 21 && !isAchievementUnlocked('night_owl')) {
        await unlockAchievement(AchievementType.nightOwl);
      }
    }
    
    // Award XP for reservation
    await awardXp(50, message: 'Réservation confirmée');
  }

  /// Called when user completes a match
  Future<void> onMatchCompleted() async {
    if (!isAchievementUnlocked('first_match')) {
      await unlockAchievement(AchievementType.firstMatch);
    }
    await awardXp(25, message: 'Match terminé');
  }

  /// Reset all progress (for testing)
  Future<void> resetProgress() async {
    _xp = 0;
    _currentStreak = 0;
    _reservationsCount = 0;
    _lastActivityDate = null;
    _unlockedAchievements.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gamification_xp');
    await prefs.remove('gamification_streak');
    await prefs.remove('gamification_reservations');
    await prefs.remove('gamification_last_activity');
    await prefs.remove('gamification_achievements');
    
    notifyListeners();
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
