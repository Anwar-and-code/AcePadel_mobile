import 'package:flutter/material.dart';

/// Design tokens for colors - AcePadel Design System
/// Based on BRAND_GUIDE.html v2.0 — Gold & Black premium palette
///
/// Palette:
/// - Primary: Bright Gold #E8C547 (the ace — premium, vibrant)
/// - Secondary: Black #1A1A1A (contrast, sophistication)
/// - Accent: Deep Gold #D4AF37
/// - Semantic: Success, Warning, Error, Info
abstract final class AppColors {
  // ==========================================================================
  // BRAND COLORS
  // ==========================================================================

  /// Primary brand color — Bright Gold #E8C547
  static const Color brandPrimary = Color(0xFFE8C547);

  /// Secondary brand color — Near-Black #1A1A1A
  static const Color brandSecondary = Color(0xFF1A1A1A);

  /// Accent brand color — Deep Gold #D4AF37
  static const Color brandAccent = Color(0xFFD4AF37);

  /// Tertiary brand color — Light Gold #F5E6B8
  static const Color brandTertiary = Color(0xFFF5E6B8);

  /// Dark Gold — for pressed/active states #B8860B
  static const Color brandDarkGold = Color(0xFFB8860B);

  // ==========================================================================
  // GOLD SCALE (from brand guide §3.2)
  // ==========================================================================

  static const Color gold50  = Color(0xFFFFF9E6);
  static const Color gold100 = Color(0xFFFFF2CC);
  static const Color gold200 = Color(0xFFF5E6B8);
  static const Color gold300 = Color(0xFFEDD88A);
  static const Color gold400 = Color(0xFFE8C547);
  static const Color gold500 = Color(0xFFD4AF37);
  static const Color gold600 = Color(0xFFC5A028);
  static const Color gold700 = Color(0xFFB8860B);
  static const Color gold800 = Color(0xFF9A7209);
  static const Color gold900 = Color(0xFF7A5A07);

  // ==========================================================================
  // BLACK / NEUTRAL SCALE (from brand guide §3.3)
  // ==========================================================================

  static const Color neutral50  = Color(0xFFF5F5F5);
  static const Color neutral100 = Color(0xFFE8E8E8);
  static const Color neutral200 = Color(0xFFD1D1D1);
  static const Color neutral300 = Color(0xFFB0B0B0);
  static const Color neutral400 = Color(0xFF888888);
  static const Color neutral500 = Color(0xFF6D6D6D);
  static const Color neutral600 = Color(0xFF5D5D5D);
  static const Color neutral700 = Color(0xFF3D3D3D);
  static const Color neutral800 = Color(0xFF2D2D2D);
  static const Color neutral900 = Color(0xFF1A1A1A);

  // ==========================================================================
  // SPECIAL SURFACES
  // ==========================================================================

  /// Off-white warm background — from brand guide §9
  static const Color offWhite = Color(0xFFFCFAF6);

  /// Cream accent background
  static const Color cream = Color(0xFFFFF8E1);

  // --- Pure Colors ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ==========================================================================
  // SEMANTIC COLORS (from brand guide §3.4)
  // ==========================================================================

  static const Color success      = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning      = Color(0xFFEF6C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error        = Color(0xFFC62828);
  static const Color errorLight   = Color(0xFFFFEBEE);
  static const Color info         = Color(0xFF1565C0);
  static const Color infoLight    = Color(0xFFE3F2FD);

  // ==========================================================================
  // SEMANTIC TOKENS — LIGHT MODE (from brand guide §9)
  // ==========================================================================

  // --- Background Colors ---
  static const Color backgroundPrimary   = offWhite;        // #FCFAF6
  static const Color backgroundSecondary = neutral50;       // #F5F5F5
  static const Color backgroundTertiary  = neutral100;      // #E8E8E8
  static const Color backgroundElevated  = white;           // #FFFFFF

  // --- Surface Colors ---
  static const Color surfaceDefault   = white;
  static const Color surfaceSubtle    = neutral50;
  static const Color surfaceMuted     = neutral100;
  static const Color surfaceHighlight = gold50;

  // --- Text Colors (from brand guide §9 light mode) ---
  static const Color textPrimary     = Color(0xFF1E1C1A);   // near-black warm
  static const Color textSecondary   = Color(0xFF575350);
  static const Color textTertiary    = Color(0xFF9A9590);
  static const Color textDisabled    = Color(0xFFB8B3AB);
  static const Color textOnPrimary   = white;
  static const Color textOnSecondary = Color(0xFF1E1C1A);
  static const Color textLink        = brandPrimary;
  static const Color textGold        = brandPrimary;

  // --- Border Colors ---
  static const Color borderDefault = neutral200;
  static const Color borderSubtle  = neutral100;
  static const Color borderStrong  = neutral400;
  static const Color borderFocus   = brandPrimary;

  // --- Icon Colors (from brand guide §8 icon colors) ---
  static const Color iconPrimary   = Color(0xFF1E1C1A);
  static const Color iconSecondary = Color(0xFF575350);
  static const Color iconTertiary  = Color(0xFF9A9590);
  static const Color iconDisabled  = Color(0xFFB8B3AB);
  static const Color iconGold      = brandPrimary;
  static const Color iconOnPrimary = white;

  // ==========================================================================
  // COMPONENT-SPECIFIC TOKENS
  // ==========================================================================

  // --- Button Colors ---
  static const Color buttonPrimaryBackground    = brandPrimary;
  static const Color buttonPrimaryForeground    = white;
  static const Color buttonSecondaryBackground  = neutral100;
  static const Color buttonSecondaryForeground  = brandSecondary;
  static const Color buttonTertiaryBackground   = Colors.transparent;
  static const Color buttonTertiaryForeground   = brandPrimary;
  static const Color buttonDisabledBackground   = neutral200;
  static const Color buttonDisabledForeground   = neutral500;

  // --- Card Colors ---
  static const Color cardBackground = white;
  static const Color cardBorder     = neutral200;
  static const Color cardShadow     = Color(0x14000000); // 8% black

  // --- Input Colors ---
  static const Color inputBackground  = white;
  static const Color inputBorder      = neutral300;
  static const Color inputBorderFocus = brandPrimary;
  static const Color inputBorderError = error;
  static const Color inputPlaceholder = neutral400;

  // --- Navigation Colors (from brand guide §9 light mode) ---
  static const Color navBarBackground         = white;
  static const Color navBarItemActive         = Color(0xFFC5A028); // gold-600
  static const Color navBarItemInactive       = neutral500;
  static const Color navBarItemActiveBackground = gold50;

  // --- Reservation Card Colors ---
  static const Color reservationTimeBadge     = brandPrimary;
  static const Color reservationTimeBadgeText = white;
  static const Color reservationCardBorder    = neutral200;

  // ==========================================================================
  // GRADIENT DEFINITIONS (from brand guide §4)
  // ==========================================================================

  /// Primary CTA gradient — buttons, heroes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8C547), Color(0xFFC5A028)],
  );

  /// Rich gold gradient — premium elements
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF0D060), Color(0xFFE8C547), Color(0xFFB8860B)],
  );

  /// Gold shimmer effect
  static const LinearGradient goldShimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEDD88A), Color(0xFFE8C547), Color(0xFFEDD88A)],
  );

  /// Dark gradient — dark mode backgrounds
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
  );

  /// Surface gradient — light mode backgrounds
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [offWhite, white],
  );
}
