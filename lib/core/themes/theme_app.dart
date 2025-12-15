// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs de la palette "Art Gallery"
  static const Color _artGalleryDeepPurple = Color(0xFF6A11CB);
  static const Color _artGalleryIndigo = Color(0xFF2575FC);
  static const Color _artGalleryTeal = Color(0xFF009688);
  static const Color _artGalleryAmber = Color(0xFFFF8F00);
  static const Color _artGalleryPink = Color(0xFFEC407A);
  static const Color _artGalleryCyan = Color(0xFF00BCD4);

  static const Color _lightBackground = Color(0xFFFAF9F7);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceVariant = Color(0xFFF2F0ED);

  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkSurface = Color(0xFF1E1E1E);
  static const Color _darkSurfaceVariant = Color(0xFF2D2D2D);

  // Effets de transparence pour glass morphism
  static const double _glassOpacityLight = 0.85;
  static const double _glassOpacityDark = 0.75;

  // Thème clair - Style "Art Gallery"
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _artGalleryDeepPurple,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE8E1F3),
      onPrimaryContainer: _artGalleryDeepPurple,

      secondary: _artGalleryIndigo,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE3E9F7),
      onSecondaryContainer: _artGalleryIndigo,

      tertiary: _artGalleryTeal,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFE0F2F1),
      onTertiaryContainer: _artGalleryTeal,

      background: _lightBackground,
      onBackground: Color(0xFF1A1A1A),

      surface: _lightSurface,
      onSurface: Color(0xFF1A1A1A),
      surfaceVariant: _lightSurfaceVariant,
      onSurfaceVariant: Color(0xFF49454F),

      outline: Color(0xFF79747E),
      outlineVariant: Color(0xFFCAC4D0),

      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
    ),

    // Éléments de design spécifiques
    scaffoldBackgroundColor: _lightBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1A1A1A),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Color(0x1A000000),
      iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
      actionsIconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),

    cardTheme: CardThemeData(
      color: _lightSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE6E1E5),
          width: 1,
        ),
      ),
      shadowColor: Colors.black.withOpacity(0.08),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _artGalleryDeepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _artGalleryDeepPurple,
        side: const BorderSide(color: _artGalleryDeepPurple, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _artGalleryDeepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _artGalleryDeepPurple,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: CircleBorder(),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedItemColor: _artGalleryDeepPurple,
      unselectedItemColor: Color(0xFF757575),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF3EDF7),
      selectedColor: _artGalleryDeepPurple,
      checkmarkColor: Colors.white,
      labelStyle: const TextStyle(color: Color(0xFF1A1A1A)),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      brightness: Brightness.light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      side: BorderSide.none,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: _lightSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFFE6E1E5),
          width: 1,
        ),
      ),
      titleTextStyle: const TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: const TextStyle(
        color: Color(0xFF49454F),
        fontSize: 14,
      ),
    ),

    listTileTheme: ListTileThemeData(
      iconColor: Color(0xFF49454F),
      textColor: Color(0xFF1A1A1A),
      tileColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFE6E1E5),
      thickness: 1,
      space: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCAC4D0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCAC4D0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _artGalleryDeepPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF79747E)),
      labelStyle: const TextStyle(color: Color(0xFF49454F)),
    ),

    useMaterial3: true,
  );

  // Thème sombre - Style "Art Gallery"
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFD0BCFF),
      onPrimary: Color(0xFF381E72),
      primaryContainer: Color(0xFF4F378B),
      onPrimaryContainer: Color(0xFFEADDFF),

      secondary: Color(0xFFCCC2DC),
      onSecondary: Color(0xFF332D41),
      secondaryContainer: Color(0xFF4A4458),
      onSecondaryContainer: Color(0xFFE8DEF8),

      tertiary: Color(0xFFEFB8C8),
      onTertiary: Color(0xFF492532),
      tertiaryContainer: Color(0xFF633B48),
      onTertiaryContainer: Color(0xFFFFD8E4),

      background: _darkBackground,
      onBackground: Color(0xFFE6E1E5),

      surface: _darkSurface,
      onSurface: Color(0xFFE6E1E5),
      surfaceVariant: _darkSurfaceVariant,
      onSurfaceVariant: Color(0xFFCAC4D0),

      outline: Color(0xFF938F99),
      outlineVariant: Color(0xFF49454F),

      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFF9DEDC),
    ),

    // Éléments de design spécifiques
    scaffoldBackgroundColor: _darkBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFE6E1E5),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Color(0x1A000000),
      iconTheme: IconThemeData(color: Color(0xFFE6E1E5)),
      actionsIconTheme: IconThemeData(color: Color(0xFFE6E1E5)),
      titleTextStyle: TextStyle(
        color: Color(0xFFE6E1E5),
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),

    cardTheme: CardThemeData(
      color: _darkSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFF36343B),
          width: 1,
        ),
      ),
      shadowColor: Colors.black.withOpacity(0.15),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD0BCFF),
        foregroundColor: const Color(0xFF381E72),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFD0BCFF),
        side: const BorderSide(color: Color(0xFFD0BCFF), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFD0BCFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFD0BCFF),
      foregroundColor: Color(0xFF381E72),
      elevation: 3,
      shape: CircleBorder(),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedItemColor: Color(0xFFD0BCFF),
      unselectedItemColor: Color(0xFF9E9E9E),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF36343B),
      selectedColor: const Color(0xFFD0BCFF),
      checkmarkColor: const Color(0xFF381E72),
      labelStyle: const TextStyle(color: Color(0xFFE6E1E5)),
      secondaryLabelStyle: const TextStyle(color: Color(0xFF381E72)),
      brightness: Brightness.dark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      side: BorderSide.none,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: _darkSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFF36343B),
          width: 1,
        ),
      ),
      titleTextStyle: const TextStyle(
        color: Color(0xFFE6E1E5),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: const TextStyle(
        color: Color(0xFFCAC4D0),
        fontSize: 14,
      ),
    ),

    listTileTheme: ListTileThemeData(
      iconColor: Color(0xFFCAC4D0),
      textColor: Color(0xFFE6E1E5),
      tileColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFF36343B),
      thickness: 1,
      space: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF49454F)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF49454F)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0BCFF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF2B8B5)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF2B8B5), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF938F99)),
      labelStyle: const TextStyle(color: Color(0xFFCAC4D0)),
    ),

    useMaterial3: true,
  );

  // Méthodes utilitaires pour le style "Art Gallery"

  static Color getSurfaceColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _darkSurface : _lightSurface;
  }

  static Color getSurfaceVariantColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _darkSurfaceVariant : _lightSurfaceVariant;
  }

  static Color getGlassColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final opacity = isDark ? _glassOpacityDark : _glassOpacityLight;
    return (isDark ? Colors.black : Colors.white).withOpacity(opacity);
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color getIconColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).colorScheme.outlineVariant;
  }

  static Color getHintColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getPrimaryContainerColor(BuildContext context) {
    return Theme.of(context).colorScheme.primaryContainer;
  }

  // Méthode pour obtenir une couleur d'accent de la palette
  static Color getAccentColor(int index) {
    final colors = [
      _artGalleryDeepPurple,
      _artGalleryIndigo,
      _artGalleryTeal,
      _artGalleryAmber,
      _artGalleryPink,
      _artGalleryCyan,
    ];
    return colors[index % colors.length];
  }

  // Méthode pour créer un dégradé artistique
  static Gradient getArtisticGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primary.withOpacity(0.1),
          primary.withOpacity(0.05),
          Colors.transparent,
        ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primary.withOpacity(0.05),
          Colors.transparent,
          primary.withOpacity(0.02),
        ],
      );
    }
  }

  // Méthode pour obtenir un style de texte artistique
  static TextStyle getArtisticTextStyle(BuildContext context, {double? fontSize, FontWeight? fontWeight}) {
    return TextStyle(
      color: getTextColor(context),
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.w400,
      letterSpacing: -0.2,
      height: 1.5,
    );
  }

  // Méthode pour obtenir un style de titre artistique
  static TextStyle getArtisticTitleStyle(BuildContext context, {double? fontSize, FontWeight? fontWeight}) {
    return TextStyle(
      color: getTextColor(context),
      fontSize: fontSize ?? 24,
      fontWeight: fontWeight ?? FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
    );
  }
}