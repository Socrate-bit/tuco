import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single source of truth for all colors used in the app.
abstract class AppColors {
  // Brand / primary
  static const primary = Color.fromARGB(255, 250, 150, 0); // bright azure (buttons, active tab)
  static const primaryDark = Color.fromARGB(255, 213, 128, 0); // 3D button bottom edge
  static const primaryLight = Color(0xFFDEEEFF); // light blue circles / user bubble
  static const navy = Color(0xFF0B4983); // titles & emphasised text
  static const textDark = Color(0xFF3A4254);
  static const titleDark = Color(0xFF212121); // section titles // chat/body text
  static const textGrey = Color(0xFF9AA1AC); // secondary text
  static const textLightGrey = Color(0xFFB9BDC3);

  // Surfaces
  static const background = Color(0xFFF2F3F5); // grey page background
  static const card = Colors.white;
  static const divider = Color(0xFFEBECEE);
  static const aiBubble = Color(0xFFF2F3F4);
  static const userBubble = Color(0xFFD8EBFF);
  static const inspirationBubble = Color(0xFFF8E8C3);
  static const feedbackFooter = Color(0xFFE4E9F2);

  // Header gradient (robot call background)
  static const headerCenter = Color(0xFF46639B);
  static const headerEdge = Color(0xFF2A3C5F);

  // Accents
  static const streakOrange = Color(0xFFFF9E0D); // fire / streak
  static const streakCream = Color(0xFFFDF3DC); // streak page header bg
  static const lessonRed = Color(0xFFF45B3D); // first lesson node / current lesson
  static const teal = Color(0xFF17CDD8); // grammaire card, teal lessons
  static const green = Color(0xFF7BC537); // alternatives card, success
  static const purple = Color(0xFF9355D1); // entraînement banner
  static const orangeBanner = Color(0xFFF2A93B); // cours banner
  static const chartBar = Color(0xFF7B8FE0); // call-time bar chart

  // Feedback score colors
  static const scoreRed = Color(0xFFF87168);
  static const scoreRedBg = Color(0xFFFDE8E8);
  static const scoreOrange = Color(0xFFF2A93B);
  static const scoreGreen = Color(0xFF3ED598);
  static const scoreGreenBg = Color(0xFF4CD08D);

  // Misc
  static const lockedNode = Color(0xFFB9BDC3);
  static const pathLine = Color(0xFFF3F4F4);
  static const whiteTranslucent = Color(0x8CFFFFFF); // pills on header
  static const levelDivider = Color(0xFFB4C7D9); // "Débutant" section label
}

/// Single source of truth for all text styles. Font: Nunito (rounded, friendly).
abstract class AppTextStyles {
  static TextStyle get _base => GoogleFonts.nunito();

  // Page titles ("Grammaire", "Exercice de vocabulaire")
  static TextStyle get pageTitle => _base.copyWith(
      fontSize: 26.sp, fontWeight: FontWeight.w800, color: AppColors.navy);

  // Section titles ("Centre de feedback", "Votre série")
  static TextStyle get sectionTitle => _base.copyWith(
      fontSize: 22.sp, fontWeight: FontWeight.w800, color: AppColors.titleDark);

  // Big display ("Cours terminé !", streak count)
  static TextStyle get display => _base.copyWith(
      fontSize: 32.sp, fontWeight: FontWeight.w800, color: AppColors.primary);

  // Modal titles
  static TextStyle get modalTitle => _base.copyWith(
      fontSize: 26.sp, fontWeight: FontWeight.w800, color: AppColors.navy);

  // Chat bubbles / body
  static TextStyle get body => _base.copyWith(
      fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.textDark);

  static TextStyle get bodyGrey => _base.copyWith(
      fontSize: 17.sp, fontWeight: FontWeight.w600, color: AppColors.textGrey);

  // List item primary text (vocab word, settings label)
  static TextStyle get itemTitle => _base.copyWith(
      fontSize: 19.sp, fontWeight: FontWeight.w800, color: AppColors.navy);

  static TextStyle get itemSubtitle => _base.copyWith(
      fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textGrey);

  // Buttons
  static TextStyle get button => _base.copyWith(
      fontSize: 19.sp, fontWeight: FontWeight.w800, color: Colors.white);

  static TextStyle get textLink => _base.copyWith(
      fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.primary);

  // Small labels (tab bar, day labels)
  static TextStyle get small => _base.copyWith(
      fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textGrey);

  static TextStyle get chip => _base.copyWith(
      fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textDark);
}

/// App-wide ThemeData built from the palette above.
abstract class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.card,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      );
}
