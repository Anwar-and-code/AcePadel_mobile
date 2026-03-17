import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Design tokens for shadows/elevation — AcePadel Design System
/// Based on BRAND_GUIDE.html v2.0 §6
///
/// Standard shadows: XS→XL with increasing blur
/// Gold Glow shadows: Premium gold-tinted shadows for accented elements
abstract final class AppShadows {
  // ==========================================================================
  // SHADOW COLORS
  // ==========================================================================

  static const Color shadowColor = AppColors.cardShadow;
  static const Color shadowColorDark = Color(0x33000000);
  static const Color shadowColorLight = Color(0x0D000000);

  // ==========================================================================
  // ELEVATION VALUES (Material 3)
  // ==========================================================================

  static const double elevationNone = 0.0;
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  // ==========================================================================
  // STANDARD BOX SHADOWS (from brand guide §6.1)
  // ==========================================================================

  static const List<BoxShadow> shadowNone = [];

  /// XS — Subtil, blur 2px
  static const List<BoxShadow> shadowXs = [
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// SM — Cards at rest, blur 4px
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// MD — Navigation, blur 8px
  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// LG — Modals, blur 16px
  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x1F000000), // 12% black
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  /// XL — Floating elements, blur 24px
  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Color(0x26000000), // 15% black
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  // ==========================================================================
  // GOLD GLOW SHADOWS (from brand guide §6.2 — Premium)
  // ==========================================================================

  /// Gold Glow Subtle — Cards, badges (#E8C547 @ 12%)
  static const List<BoxShadow> goldGlowSubtle = [
    BoxShadow(
      color: Color(0x1FE8C547),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Gold Glow — Premium elements (#E8C547 @ 25%)
  static const List<BoxShadow> goldGlow = [
    BoxShadow(
      color: Color(0x40E8C547),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x1AE8C547),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Gold Glow Intense — CTA, heroes (#E8C547 @ 40%)
  static const List<BoxShadow> goldGlowIntense = [
    BoxShadow(
      color: Color(0x66E8C547),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 2,
    ),
    BoxShadow(
      color: Color(0x33E8C547),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // ==========================================================================
  // COMPONENT-SPECIFIC SHADOWS
  // ==========================================================================

  /// Card shadow — Default card elevation
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Card shadow on hover/focus
  static const List<BoxShadow> cardShadowHover = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Button shadow
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x1AE8C547), // Gold tint for brand buttons
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Navigation bar shadow
  static const List<BoxShadow> navBarShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, -2),
    ),
  ];

  /// Bottom sheet shadow
  static const List<BoxShadow> bottomSheetShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, -4),
    ),
  ];

  /// Input focus shadow — gold glow on focus
  static List<BoxShadow> inputFocusShadow = [
    BoxShadow(
      color: AppColors.brandPrimary.withValues(alpha: 0.15),
      blurRadius: 4,
      offset: Offset.zero,
      spreadRadius: 2,
    ),
  ];

  /// Image/banner shadow
  static const List<BoxShadow> imageShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // ==========================================================================
  // INNER SHADOWS (for pressed states)
  // ==========================================================================

  static const List<BoxShadow> innerShadowSm = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: -1,
    ),
  ];
}
