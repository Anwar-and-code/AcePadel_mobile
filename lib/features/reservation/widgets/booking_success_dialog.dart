import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/design_system/design_system.dart';
import '../models/reservation.dart';

class BookingSuccessDialog extends StatefulWidget {
  const BookingSuccessDialog({
    super.key,
    required this.reservation,
    required this.onDismiss,
  });

  final Reservation reservation;
  final VoidCallback onDismiss;

  static Future<void> show(BuildContext context, Reservation reservation, VoidCallback onDismiss) {
    HapticFeedback.heavyImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: AppAnimations.durationMedium,
      pageBuilder: (context, animation, secondaryAnimation) {
        return BookingSuccessDialog(
          reservation: reservation,
          onDismiss: onDismiss,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AppAnimations.curveDecelerate,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<BookingSuccessDialog> createState() => _BookingSuccessDialogState();
}

class _BookingSuccessDialogState extends State<BookingSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _contentController;
  late AnimationController _confettiController;
  
  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;
  late Animation<double> _ringScale;
  late Animation<double> _contentSlide;
  late Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    
    _checkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    
    _ringScale = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _contentSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _checkController.forward();
    _confettiController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _contentController.forward();
  }

  @override
  void dispose() {
    _checkController.dispose();
    _contentController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final dayNames = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final monthNames = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    return '${dayNames[date.weekday - 1]} ${date.day} ${monthNames[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Confetti animation
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ConfettiPainter(
                  progress: _confettiController.value,
                ),
              );
            },
          ),
          // Main dialog
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 380),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDefault.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.2),
                          blurRadius: 40,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 40),
                        _buildSuccessIcon(),
                        const SizedBox(height: 24),
                        _buildContent(),
                        const SizedBox(height: 32),
                        _buildButton(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return AnimatedBuilder(
      animation: _checkController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Transform.scale(
              scale: _ringScale.value,
              child: Opacity(
                opacity: (1 - _checkController.value).clamp(0.0, 0.5),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.success,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
            // Success circle
            Transform.scale(
              scale: _checkScale.value,
              child: Opacity(
                opacity: _checkOpacity.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.success,
                        AppColors.success.withValues(alpha: 0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: 56,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _contentSlide.value),
          child: Opacity(
            opacity: _contentOpacity.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Réservation confirmée !',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Votre court vous attend',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Reservation details card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          Icons.confirmation_number_outlined,
                          'Référence',
                          widget.reservation.reference,
                          AppColors.brandPrimary,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: AppColors.borderDefault),
                        ),
                        _buildDetailRow(
                          Icons.calendar_today_outlined,
                          'Date',
                          _formatDate(widget.reservation.reservationDate),
                          AppColors.brandSecondary,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: AppColors.borderDefault),
                        ),
                        _buildDetailRow(
                          Icons.access_time_rounded,
                          'Horaire',
                          '${widget.reservation.formattedStartTime} - ${widget.reservation.formattedEndTime}',
                          AppColors.info,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: AppColors.borderDefault),
                        ),
                        _buildDetailRow(
                          Icons.sports_tennis_outlined,
                          'Court',
                          'Court ${widget.reservation.terrainCode ?? '--'}',
                          AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton() {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return Opacity(
          opacity: _contentOpacity.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandPrimary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onDismiss();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Voir mes réservations',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  
  _ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    
    final colors = [
      AppColors.success,
      AppColors.brandPrimary,
      AppColors.brandSecondary,
      AppColors.gold400,
      AppColors.info,
    ];
    
    final random = [
      0.1, 0.25, 0.4, 0.55, 0.7, 0.85, 0.15, 0.3, 0.45, 0.6, 0.75, 0.9,
      0.05, 0.2, 0.35, 0.5, 0.65, 0.8, 0.95, 0.12, 0.28, 0.42, 0.58, 0.72,
    ];
    
    for (int i = 0; i < 24; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: (1 - progress) * 0.8)
        ..style = PaintingStyle.fill;
      
      final x = size.width * random[i];
      final startY = size.height * 0.3;
      final endY = size.height * (0.6 + random[(i + 5) % random.length] * 0.4);
      final y = startY + (endY - startY) * progress;
      
      final rotation = progress * 3.14159 * 2 * (i % 2 == 0 ? 1 : -1);
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      
      if (i % 3 == 0) {
        canvas.drawCircle(Offset.zero, 4 + (i % 4), paint);
      } else if (i % 3 == 1) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: 8, height: 8),
          paint,
        );
      } else {
        final path = Path()
          ..moveTo(0, -6)
          ..lineTo(5, 6)
          ..lineTo(-5, 6)
          ..close();
        canvas.drawPath(path, paint);
      }
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
