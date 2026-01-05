import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/gamification_service_v2.dart';

class XpProgressBar extends StatelessWidget {
  final bool showLevel;
  final bool compact;

  const XpProgressBar({
    super.key,
    this.showLevel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GamificationServiceV2.instance,
      builder: (context, _) {
        final service = GamificationServiceV2.instance;
        
        if (compact) {
          return _buildCompact(service);
        }
        
        return _buildFull(service);
      },
    );
  }

  Widget _buildCompact(GamificationServiceV2 service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Level Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Nv.${service.level}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Mini progress bar
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: service.currentLevelProgress,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${service.xp} XP',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFull(GamificationServiceV2 service) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Level and XP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Level Badge
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${service.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Niveau ${service.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getLevelTitle(service.level),
                        style: TextStyle(
                          color: const Color(0xFF6C63FF).withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Total XP
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFD93D),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.xp}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'XP Total',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progression',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${service.xpToNextLevel} XP restants',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  // Background
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  // Progress
                  FractionallySizedBox(
                    widthFactor: service.currentLevelProgress.clamp(0.0, 1.0),
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF9B59B6), Color(0xFFFF6B6B)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ).animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.2)),
                ],
              ),
            ],
          ),
          
          // Streak indicator if active
          if (service.currentStreak > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C00).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Color(0xFFFF8C00),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${service.currentStreak} jours de suite !',
                    style: const TextStyle(
                      color: Color(0xFFFF8C00),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getLevelTitle(int level) {
    if (level >= 20) return '🏆 Légende du Padel';
    if (level >= 15) return '⭐ Expert';
    if (level >= 10) return '🎯 Champion';
    if (level >= 7) return '🔥 Confirmé';
    if (level >= 4) return '🎾 Régulier';
    if (level >= 2) return '👋 Débutant';
    return '🌱 Nouveau';
  }
}
