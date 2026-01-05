import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamificationService extends ChangeNotifier {
  static final GamificationService instance = GamificationService._();

  GamificationService._() {
    _loadProgress();
  }

  int _xp = 0;
  int get xp => _xp;

  int get level => (_xp / 100).floor() + 1;

  double get currentLevelProgress {
    final int nextLevelXp = level * 100;
    final int currentLevelStartXp = (level - 1) * 100;
    return (_xp - currentLevelStartXp) / (nextLevelXp - currentLevelStartXp);
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _xp = prefs.getInt('user_xp') ?? 0;
    notifyListeners();
  }

  Future<void> addXp(int amount, BuildContext context) async {
    final int oldLevel = level;
    _xp += amount;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_xp', _xp);
    notifyListeners();

    if (level > oldLevel) {
      // Level Up!
      // In a real app, we might trigger a specific Level Up dialog here via a stream or callback
      // For now, the UI call sites can handle the visual feedback based on the returned future or local state
    }
  }
}
