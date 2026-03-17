import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../tokens/app_colors.dart';

enum AppLogoSize { small, medium, large, xlarge }

enum AppLogoVariant { full, textOnly, iconOnly, stacked, monogram }

/// AcePadel Logo Widget - Brand Guide v2.0 Section 2
///
/// Variants:
/// - [full]: Golden ball icon + "acepadel" text side by side
/// - [textOnly]: "acepadel" text only (navigation, headers)
/// - [iconOnly]: Golden ball with "A" motif (favicon, app icon)
/// - [stacked]: Icon above text (splash, marketing)
/// - [monogram]: Circular golden "A" (avatars, badges)
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = AppLogoSize.medium,
    this.variant = AppLogoVariant.full,
    this.onDark = false,
    this.color,
  });

  final AppLogoSize size;
  final AppLogoVariant variant;
  final bool onDark;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AppLogoVariant.full:
        return _buildFull();
      case AppLogoVariant.textOnly:
        return _buildTextOnly();
      case AppLogoVariant.iconOnly:
        return _buildIconOnly();
      case AppLogoVariant.stacked:
        return _buildStacked();
      case AppLogoVariant.monogram:
        return _buildMonogram();
    }
  }

  Widget _buildFull() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GoldenBall(size: _iconSize),
        SizedBox(width: _iconSize * 0.22),
        _AcePadelText(fontSize: _textSize, onDark: onDark, color: color),
      ],
    );
  }

  Widget _buildTextOnly() {
    return _AcePadelText(fontSize: _textSize, onDark: onDark, color: color);
  }

  Widget _buildIconOnly() => _GoldenBall(size: _iconSize);

  Widget _buildStacked() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GoldenBall(size: _iconSize),
        SizedBox(height: _iconSize * 0.15),
        _AcePadelText(fontSize: _textSize * 0.75, onDark: onDark, color: color),
      ],
    );
  }

  Widget _buildMonogram() {
    final s = _iconSize;
    return Container(
      width: s,
      height: s,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0D060), Color(0xFFE8C547), Color(0xFFD4AF37)],
        ),
        boxShadow: [
          BoxShadow(color: Color(0x33E8C547), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'A',
        style: GoogleFonts.nunito(
          fontSize: s * 0.52,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }

  double get _iconSize {
    switch (size) {
      case AppLogoSize.small:   return 28;
      case AppLogoSize.medium:  return 40;
      case AppLogoSize.large:   return 56;
      case AppLogoSize.xlarge:  return 72;
    }
  }

  double get _textSize {
    switch (size) {
      case AppLogoSize.small:   return 16;
      case AppLogoSize.medium:  return 22;
      case AppLogoSize.large:   return 30;
      case AppLogoSize.xlarge:  return 38;
    }
  }
}

/// "acepadel" text with "ace" in gold and "padel" in black/white
class _AcePadelText extends StatelessWidget {
  const _AcePadelText({
    required this.fontSize,
    this.onDark = false,
    this.color,
  });

  final double fontSize;
  final bool onDark;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final padelColor = color ?? (onDark ? Colors.white : AppColors.brandSecondary);
    final aceColor = color ?? AppColors.brandPrimary;
    final style = GoogleFonts.nunito(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: 1,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('ace', style: style.copyWith(color: aceColor)),
        Text('padel', style: style.copyWith(color: padelColor)),
      ],
    );
  }
}

/// Golden ball with "A" motif - painted via CustomPainter
class _GoldenBall extends StatelessWidget {
  const _GoldenBall({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoldenBallPainter()),
    );
  }
}

class _GoldenBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.46;

    // Gold gradient fill
    final gradient = const RadialGradient(
      center: Alignment(-0.3, -0.3),
      radius: 1.0,
      colors: [Color(0xFFF0D060), Color(0xFFE8C547), Color(0xFFD4AF37)],
      stops: [0.0, 0.5, 1.0],
    );
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, paint);

    // Subtle curve accent (ball seam)
    final curvePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02
      ..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(size.width * 0.36, size.height * 0.28);
    path.cubicTo(
      size.width * 0.58, size.height * 0.38,
      size.width * 0.36, size.height * 0.62,
      size.width * 0.64, size.height * 0.72,
    );
    canvas.drawPath(path, curvePaint);

    // Highlight bubble
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18);
    canvas.drawCircle(
      Offset(size.width * 0.38, size.height * 0.36),
      size.width * 0.05,
      highlightPaint,
    );

    // "A" letter
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'A',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: size.width * 0.52,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2 + size.height * 0.04,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
