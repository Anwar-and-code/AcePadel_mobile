import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Design tokens for typography — AcePadel Design System
/// Based on BRAND_GUIDE.html v2.0 §5
///
/// Font families:
/// - Nunito: Rounded geometric sans-serif — ALL text (headlines, body, labels)
/// - JetBrains Mono: Monospace — codes & numbers
///
/// Scale: Material 3 type scale with brand-specific sizes
abstract final class AppTypography {
  // ==========================================================================
  // FONT FAMILIES
  // ==========================================================================

  /// Primary font — Nunito (rounded geometric sans-serif)
  static String get fontFamilyPrimary => GoogleFonts.nunito().fontFamily!;

  /// Alias — headlines also use Nunito per brand guide
  static String get fontFamilySecondary => GoogleFonts.nunito().fontFamily!;

  /// Monospace font — JetBrains Mono (codes & numbers)
  static String get fontFamilyMono => GoogleFonts.jetBrainsMono().fontFamily!;

  // ==========================================================================
  // FONT WEIGHTS
  // ==========================================================================

  static const FontWeight weightThin = FontWeight.w100;
  static const FontWeight weightExtraLight = FontWeight.w200;
  static const FontWeight weightLight = FontWeight.w300;
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;
  static const FontWeight weightExtraBold = FontWeight.w800;
  static const FontWeight weightBlack = FontWeight.w900;

  // ==========================================================================
  // FONT SIZES (from brand guide §5.2 hierarchy table)
  // ==========================================================================

  static const double fontSize10 = 10.0;
  static const double fontSize11 = 11.0;
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize22 = 22.0;
  static const double fontSize24 = 24.0;
  static const double fontSize26 = 26.0;
  static const double fontSize28 = 28.0;
  static const double fontSize32 = 32.0;
  static const double fontSize36 = 36.0;
  static const double fontSize48 = 48.0;
  static const double fontSize56 = 56.0;

  // ==========================================================================
  // LINE HEIGHTS
  // ==========================================================================

  static const double lineHeightTight = 1.1;
  static const double lineHeightSnug = 1.25;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.5;
  static const double lineHeightLoose = 1.75;

  // ==========================================================================
  // LETTER SPACING
  // ==========================================================================

  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingWider = 1.0;

  // ==========================================================================
  // TEXT STYLES — DISPLAY (Splash, heroes) — Nunito Bold
  // ==========================================================================

  static TextStyle get displayLarge => GoogleFonts.nunito(
    fontSize: fontSize56,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => GoogleFonts.nunito(
    fontSize: fontSize48,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: AppColors.textPrimary,
  );

  static TextStyle get displaySmall => GoogleFonts.nunito(
    fontSize: fontSize36,
    fontWeight: weightBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingTight,
    color: AppColors.textPrimary,
  );

  // ==========================================================================
  // TEXT STYLES — HEADLINE (Page titles, sections) — Nunito Bold/SemiBold
  // ==========================================================================

  static TextStyle get headlineLarge => GoogleFonts.nunito(
    fontSize: fontSize32,
    fontWeight: weightBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => GoogleFonts.nunito(
    fontSize: fontSize28,
    fontWeight: weightSemiBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineSmall => GoogleFonts.nunito(
    fontSize: fontSize24,
    fontWeight: weightSemiBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  // ==========================================================================
  // TEXT STYLES — TITLE (Card titles, list headers) — Nunito SemiBold/Medium
  // ==========================================================================

  static TextStyle get titleLarge => GoogleFonts.nunito(
    fontSize: fontSize22,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.nunito(
    fontSize: fontSize18,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleSmall => GoogleFonts.nunito(
    fontSize: fontSize16,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  // ==========================================================================
  // TEXT STYLES — BODY (Main content) — Nunito Regular
  // ==========================================================================

  static TextStyle get bodyLarge => GoogleFonts.nunito(
    fontSize: fontSize16,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
    fontSize: fontSize14,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.nunito(
    fontSize: fontSize12,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textSecondary,
  );

  // ==========================================================================
  // TEXT STYLES — LABEL (Buttons, form labels, navigation) — Nunito Medium
  // ==========================================================================

  static TextStyle get labelLarge => GoogleFonts.nunito(
    fontSize: fontSize16,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => GoogleFonts.nunito(
    fontSize: fontSize14,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelSmall => GoogleFonts.nunito(
    fontSize: fontSize12,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
    color: AppColors.textSecondary,
  );

  // ==========================================================================
  // TEXT STYLES — CAPTION & OVERLINE
  // ==========================================================================

  static TextStyle get caption => GoogleFonts.nunito(
    fontSize: fontSize11,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textTertiary,
  );

  static TextStyle get overline => GoogleFonts.nunito(
    fontSize: fontSize10,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWider,
    color: AppColors.textSecondary,
  );

  // ==========================================================================
  // COMPONENT-SPECIFIC TEXT STYLES
  // ==========================================================================

  // --- Button Text ---
  static TextStyle get buttonLarge => GoogleFonts.nunito(
    fontSize: fontSize16,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  static TextStyle get buttonMedium => GoogleFonts.nunito(
    fontSize: fontSize14,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  static TextStyle get buttonSmall => GoogleFonts.nunito(
    fontSize: fontSize12,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  // --- Input Text ---
  static TextStyle get inputText => GoogleFonts.nunito(
    fontSize: fontSize16,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle get inputLabel => GoogleFonts.nunito(
    fontSize: fontSize14,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textSecondary,
  );

  static TextStyle get inputHint => GoogleFonts.nunito(
    fontSize: fontSize16,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.inputPlaceholder,
  );

  static TextStyle get inputError => GoogleFonts.nunito(
    fontSize: fontSize12,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.error,
  );

  // --- Navigation Text ---
  static TextStyle get navLabel => GoogleFonts.nunito(
    fontSize: fontSize12,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  // --- Badge Text ---
  static TextStyle get badge => GoogleFonts.nunito(
    fontSize: fontSize11,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  // --- Brand Name (logo text "acepadel") — Nunito ExtraBold §5.2 ---
  static TextStyle get brandName => GoogleFonts.nunito(
    fontSize: fontSize26,
    fontWeight: weightExtraBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingNormal,
  );

  // --- Brand Tagline — Nunito Light §5.2 ---
  static TextStyle get brandTagline => GoogleFonts.nunito(
    fontSize: fontSize12,
    fontWeight: weightLight,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWider,
  );

  // --- App Bar Title (Brand logo style) ---
  static TextStyle get appBarTitle => GoogleFonts.nunito(
    fontSize: fontSize24,
    fontWeight: weightExtraBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.brandPrimary,
  );

  // ==========================================================================
  // HELPER METHOD — Get TextTheme for Material Theme
  // ==========================================================================

  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
