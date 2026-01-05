import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../models/achievement.dart';
import '../models/gamification_event.dart';
import '../services/gamification_service_v2.dart';

class CelebrationOverlay extends StatefulWidget {
  final Widget child;

  const CelebrationOverlay({super.key, required this.child});

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> {
  late ConfettiController _confettiController;
  StreamSubscription<GamificationEvent>? _eventSubscription;
  
  GamificationEvent? _currentEvent;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    _eventSubscription = GamificationServiceV2.instance.events.listen(_handleEvent);
  }

  void _handleEvent(GamificationEvent event) {
    switch (event.type) {
      case GamificationEventType.xpEarned:
        _showXpToast(event);
        break;
      case GamificationEventType.levelUp:
        _showLevelUpCelebration(event);
        break;
      case GamificationEventType.achievementUnlocked:
        _showAchievementCelebration(event);
        break;
      case GamificationEventType.streakUpdated:
        // Could show streak animation
        break;
    }
  }

  void _showXpToast(GamificationEvent event) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _XpToastContent(
          xpAmount: event.xpAmount ?? 0,
          message: event.message,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
      ),
    );
  }

  void _showLevelUpCelebration(GamificationEvent event) {
    setState(() {
      _currentEvent = event;
      _showOverlay = true;
    });
    _confettiController.play();
    
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showOverlay = false;
          _currentEvent = null;
        });
      }
    });
  }

  void _showAchievementCelebration(GamificationEvent event) {
    setState(() {
      _currentEvent = event;
      _showOverlay = true;
    });
    _confettiController.play();
    
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showOverlay = false;
          _currentEvent = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _eventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        
        // Confetti from top center
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Color(0xFF6C63FF),
              Color(0xFFFF6B6B),
              Color(0xFFFFD93D),
              Color(0xFF4ECDC4),
              Color(0xFFFF8C00),
              Color(0xFF9B59B6),
            ],
            numberOfParticles: 50,
            gravity: 0.1,
            emissionFrequency: 0.05,
            maxBlastForce: 20,
            minBlastForce: 8,
          ),
        ),
        
        // Celebration overlay
        if (_showOverlay && _currentEvent != null)
          _buildCelebrationCard(),
      ],
    );
  }

  Widget _buildCelebrationCard() {
    final event = _currentEvent!;
    
    if (event.type == GamificationEventType.levelUp) {
      return _LevelUpCard(level: event.newLevel ?? 1);
    }
    
    if (event.type == GamificationEventType.achievementUnlocked && event.achievement != null) {
      return _AchievementCard(achievement: event.achievement!);
    }
    
    return const SizedBox.shrink();
  }
}

class _XpToastContent extends StatelessWidget {
  final int xpAmount;
  final String? message;

  const _XpToastContent({required this.xpAmount, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.95),
            const Color(0xFF9B59B6).withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+$xpAmount XP',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (message != null)
                Text(
                  message!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 300.ms, curve: Curves.elasticOut)
      .shimmer(delay: 500.ms, duration: 1000.ms, color: Colors.white.withOpacity(0.3));
  }
}

class _LevelUpCard extends StatelessWidget {
  final int level;

  const _LevelUpCard({required this.level});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a1a2e),
                Color(0xFF16213e),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFFFFD700),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie Trophy Animation
              SizedBox(
                height: 150,
                width: 150,
                child: Lottie.network(
                  'https://assets2.lottiefiles.com/packages/lf20_touohxv0.json',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.emoji_events_rounded,
                    size: 100,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Level Up Text
              const Text(
                'NIVEAU SUPÉRIEUR !',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ).animate()
                .fadeIn(delay: 300.ms)
                .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
              
              const SizedBox(height: 16),
              
              // Level Number
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'NIVEAU $level',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate(delay: 500.ms)
                .fadeIn()
                .scale(begin: const Offset(0, 0), curve: Curves.elasticOut),
              
              const SizedBox(height: 24),
              
              Text(
                'Continuez comme ça ! 🎉',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ).animate(delay: 800.ms).fadeIn(),
              
              const SizedBox(height: 24),
              
              // Tap to dismiss
              Text(
                'Touchez pour continuer',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ).animate(delay: 1000.ms, onPlay: (c) => c.repeat(reverse: true))
                .fadeIn()
                .then()
                .fadeOut(duration: 1000.ms),
            ],
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1a1a2e),
                achievement.color.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: achievement.color,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: achievement.color.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Achievement Badge
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      achievement.color,
                      achievement.color.withOpacity(0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: achievement.color.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: achievement.lottieUrl != null
                    ? ClipOval(
                        child: Lottie.network(
                          achievement.lottieUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            achievement.icon,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        achievement.icon,
                        size: 60,
                        color: Colors.white,
                      ),
              ).animate()
                .scale(begin: const Offset(0, 0), duration: 600.ms, curve: Curves.elasticOut)
                .then()
                .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.3)),
              
              const SizedBox(height: 24),
              
              // Unlocked Text
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: achievement.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: achievement.color.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_open_rounded,
                      color: achievement.color,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SUCCÈS DÉBLOQUÉ',
                      style: TextStyle(
                        color: achievement.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: -0.5),
              
              const SizedBox(height: 16),
              
              // Achievement Title
              Text(
                achievement.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 500.ms).fadeIn().scale(),
              
              const SizedBox(height: 8),
              
              // Achievement Description
              Text(
                achievement.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 600.ms).fadeIn(),
              
              const SizedBox(height: 20),
              
              // XP Reward
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C63FF),
                      achievement.color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '+${achievement.xpReward} XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 800.ms)
                .fadeIn()
                .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
              
              const SizedBox(height: 24),
              
              // Tap to dismiss
              Text(
                'Touchez pour continuer',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ).animate(delay: 1200.ms, onPlay: (c) => c.repeat(reverse: true))
                .fadeIn()
                .then()
                .fadeOut(duration: 1000.ms),
            ],
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
      ),
    );
  }
}
