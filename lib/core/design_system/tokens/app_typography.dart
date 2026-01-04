import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Design tokens for typography - PadelHouse Design System
/// Based on Material 3 type scale with brand customizations
/// 
/// Font families:
/// - Space Grotesk: Modern geometric font for headlines (sporty, dynamic)
/// - Inter: Highly readable sans-serif for body text (designed for screens)
/// 
/// Scale: Follows Material 3 type scale ratios
abstract final class AppTypography {
  // ==========================================================================
  // FONT FAMILIES (using Google Fonts)
  // ==========================================================================
  
  /// Primary font family for body text - Inter (highly readable)
  static String get fontFamilyPrimary => GoogleFonts.inter().fontFamily!;
  
  /// Secondary font family for headings - Space Grotesk (modern, sporty)
  static String get fontFamilySecondary => GoogleFonts.spaceGrotesk().fontFamily!;
  
  /// Monospace font family for code/numbers - JetBrains Mono
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
  // FONT SIZES (Primitive tokens) - Increased for better readability
  // ==========================================================================
  
  static const double fontSize10 = 11.0;
  static const double fontSize11 = 12.0;
  static const double fontSize12 = 13.0;
  static const double fontSize13 = 14.0;
  static const double fontSize14 = 15.0;
  static const double fontSize16 = 17.0;
  static const double fontSize18 = 19.0;
  static const double fontSize20 = 21.0;
  static const double fontSize22 = 23.0;
  static const double fontSize24 = 26.0;
  static const double fontSize28 = 30.0;
  static const double fontSize32 = 34.0;
  static const double fontSize36 = 38.0;
  static const double fontSize40 = 42.0;
  static const double fontSize48 = 50.0;
  static const double fontSize56 = 58.0;
  static const double fontSize64 = 66.0;

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
  // TEXT STYLES - DISPLAY (Hero text, splash screens) - Space Grotesk
  // ==========================================================================
  
  static TextStyle get displayLarge => GoogleFonts.spaceGrotesk(
    fontSize: fontSize56,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get displayMedium => GoogleFonts.spaceGrotesk(
    fontSize: fontSize48,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get displaySmall => GoogleFonts.spaceGrotesk(
    fontSize: fontSize36,
    fontWeight: weightBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingTight,
    color: AppColors.textPrimary,
  );

  // ==========================================================================
  // TEXT STYLES - HEADLINE (Page titles, section headers) - Space Grotesk
  // ==========================================================================
  
  static TextStyle get headlineLarge => GoogleFonts.spaceGrotesk(
    fontSize: fontSize32,
    fontWeight: weightBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get headlineMedium => GoogleFonts.spaceGrotesk(
    fontSize: fontSize28,
    fontWeight: weightSemiBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get headlineSmall => GoogleFonts.spaceGrotesk(
    fontSize: fontSize24,
    fontWeight: weightSemiBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  // ==========================================================================
  // TEXT STYLES - TITLE (Card titles, list headers) - Space Grotesk
  // ==========================================================================
  
  static TextStyle get titleLarge => GoogleFonts.spaceGrotesk(
    fontSize: fontSize22,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get titleMedium => GoogleFonts.spaceGrotesk(
    fontSize: fontSize18,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get titleSmall => GoogleFonts.spaceGrotesk(
    fontSize: fontSize16,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  // ==========================================================================
  // TEXT STYLES - BODY (Main content text) - Inter
  // ==========================================================================
  
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: fontSize16,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: fontSize14,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: fontSize12,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textSecondary,
  );

  // ==========================================================================
  // TEXT STYLES - LABEL (Buttons, form labels, navigation) - Inter
  // ==========================================================================
  
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: fontSize16,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: fontSize14,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: fontSize12,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
    color: AppColors.textSecondary,
  );

  // ==========================================================================
  // TEXT STYLES - CAPTION & OVERLINE - Inter
  // ==========================================================================
  
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: fontSize11,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textTertiary,
  );
  
  static TextStyle get overline => GoogleFonts.inter(
    fontSize: fontSize10,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWider,
    color: AppColors.textSecondary,
  );

  // ==========================================================================
  // COMPONENT-SPECIFIC TEXT STYLES
  // ==========================================================================
  
  // --- Button Text --- Inter (readable for actions)
  static TextStyle get buttonLarge => GoogleFonts.inter(
    fontSize: fontSize16,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );
  
  static TextStyle get buttonMedium => GoogleFonts.inter(
    fontSize: fontSize14,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );
  
  static TextStyle get buttonSmall => GoogleFonts.inter(
    fontSize: fontSize12,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );
  
  // --- Input Text --- Inter (readable for forms)
  static TextStyle get inputText => GoogleFonts.inter(
    fontSize: fontSize16,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get inputLabel => GoogleFonts.inter(
    fontSize: fontSize14,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textSecondary,
  );
  
  static TextStyle get inputHint => GoogleFonts.inter(
    fontSize: fontSize16,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.inputPlaceholder,
  );
  
  static TextStyle get inputError => GoogleFonts.inter(
    fontSize: fontSize12,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.error,
  );
  
  // --- Navigation Text --- Inter
  static TextStyle get navLabel => GoogleFonts.inter(
    fontSize: fontSize12,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );
  
  // --- Badge Text --- Inter
  static TextStyle get badge => GoogleFonts.inter(
    fontSize: fontSize11,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );
  
  // --- App Bar Title (Brand logo style) --- Space Grotesk
  static TextStyle get appBarTitle => GoogleFonts.spaceGrotesk(
    fontSize: fontSize24,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
    color: AppColors.brandPrimary,
  );

  // ==========================================================================
  // HELPER METHOD - Get TextTheme for Material Theme
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
