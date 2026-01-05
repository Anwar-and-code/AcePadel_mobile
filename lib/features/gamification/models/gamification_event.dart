import 'achievement.dart';

enum GamificationEventType {
  xpEarned,
  levelUp,
  achievementUnlocked,
  streakUpdated,
}

class GamificationEvent {
  final GamificationEventType type;
  final int? xpAmount;
  final int? newLevel;
  final Achievement? achievement;
  final int? streakDays;
  final String? message;

  const GamificationEvent({
    required this.type,
    this.xpAmount,
    this.newLevel,
    this.achievement,
    this.streakDays,
    this.message,
  });

  factory GamificationEvent.xpEarned(int amount, {String? message}) {
    return GamificationEvent(
      type: GamificationEventType.xpEarned,
      xpAmount: amount,
      message: message,
    );
  }

  factory GamificationEvent.levelUp(int newLevel) {
    return GamificationEvent(
      type: GamificationEventType.levelUp,
      newLevel: newLevel,
    );
  }

  factory GamificationEvent.achievementUnlocked(Achievement achievement) {
    return GamificationEvent(
      type: GamificationEventType.achievementUnlocked,
      achievement: achievement,
      xpAmount: achievement.xpReward,
    );
  }

  factory GamificationEvent.streakUpdated(int days) {
    return GamificationEvent(
      type: GamificationEventType.streakUpdated,
      streakDays: days,
    );
  }
}
