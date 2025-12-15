import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static const String _accentColorKey = 'accent_color';
  static const String _glassEffectKey = 'glass_effect';

  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = Colors.deepPurple;
  bool _glassEffectEnabled = true;
  double _glassOpacity = 0.85;

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  bool get glassEffectEnabled => _glassEffectEnabled;
  double get glassOpacity => _glassOpacity;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemTheme => _themeMode == ThemeMode.system;

  // Palette de couleurs artistiques pour le thème "Art Gallery"
  final List<Color> _artGalleryPalette = [
    Colors.deepPurple,      // Principal
    Colors.indigoAccent,    // Alternative 1
    Colors.teal,            // Alternative 2
    Colors.amber[800]!,     // Alternative 3
    Colors.pinkAccent,      // Alternative 4
    Colors.cyan,            // Alternative 5
  ];

  List<Color> get availableAccentColors => _artGalleryPalette;

  ThemeManager() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Charger le thème
      final savedTheme = prefs.getString(_themeKey);
      if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }

      // Charger la couleur d'accent
      final savedColor = prefs.getInt(_accentColorKey);
      if (savedColor != null) {
        _accentColor = Color(savedColor);
      }

      // Charger l'effet glass
      _glassEffectEnabled = prefs.getBool(_glassEffectKey) ?? true;

      notifyListeners();
    } catch (e) {
      print('Erreur chargement préférences: $e');
      _themeMode = ThemeMode.system;
    }
  }

  // Changer le thème avec animation optionnelle
  Future<void> toggleTheme(bool isDark, {bool? toDark, bool animated = true}) async {
    if (toDark != null) {
      _themeMode = toDark ? ThemeMode.dark : ThemeMode.light;
    } else {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    }

    await _saveTheme();

    // Notification avec un léger délai pour permettre aux animations de se terminer
    if (animated) {
      Future.delayed(const Duration(milliseconds: 100), () {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  Future<void> setSystemTheme({bool animated = true}) async {
    _themeMode = ThemeMode.system;
    await _saveTheme();

    if (animated) {
      Future.delayed(const Duration(milliseconds: 100), () {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode, {bool animated = true}) async {
    _themeMode = mode;
    await _saveTheme();

    if (animated) {
      Future.delayed(const Duration(milliseconds: 100), () {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  // Gestion de la couleur d'accent
  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    await _saveAccentColor();
    notifyListeners();
  }

  Future<void> cycleAccentColor() async {
    final currentIndex = _artGalleryPalette.indexOf(_accentColor);
    final nextIndex = (currentIndex + 1) % _artGalleryPalette.length;
    _accentColor = _artGalleryPalette[nextIndex];
    await _saveAccentColor();
    notifyListeners();
  }

  // Gestion de l'effet glass
  Future<void> toggleGlassEffect() async {
    _glassEffectEnabled = !_glassEffectEnabled;
    await _saveGlassEffect();
    notifyListeners();
  }

  Future<void> setGlassOpacity(double opacity) async {
    _glassOpacity = opacity.clamp(0.3, 0.95);
    notifyListeners();
  }

  // Méthodes de sauvegarde
  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeValue;

      if (_themeMode == ThemeMode.dark) {
        themeValue = 'dark';
      } else if (_themeMode == ThemeMode.light) {
        themeValue = 'light';
      } else {
        themeValue = 'system';
      }

      await prefs.setString(_themeKey, themeValue);
    } catch (e) {
      print(' Erreur sauvegarde thème: $e');
    }
  }

  Future<void> _saveAccentColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_accentColorKey, _accentColor.value);
    } catch (e) {
      print('Erreur sauvegarde couleur: $e');
    }
  }

  Future<void> _saveGlassEffect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_glassEffectKey, _glassEffectEnabled);
    } catch (e) {
      print('Erreur sauvegarde effet glass: $e');
    }
  }

  // Méthodes utilitaires pour obtenir des couleurs adaptées au thème
  Color getSurfaceColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.surface.withOpacity(_glassOpacity);
  }

  Color getGlassColor(BuildContext context) {
    if (!_glassEffectEnabled) {
      return Theme.of(context).colorScheme.surface;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return (isDark ? Colors.black : Colors.white).withOpacity(_glassOpacity);
  }

  Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  Color getAccentVariant(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? HSLColor.fromColor(_accentColor).withLightness(0.7).toColor()
        : HSLColor.fromColor(_accentColor).withLightness(0.4).toColor();
  }

  // Méthode pour réinitialiser toutes les préférences
  Future<void> resetAllPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _themeMode = ThemeMode.system;
      _accentColor = Colors.deepPurple;
      _glassEffectEnabled = true;
      _glassOpacity = 0.85;

      notifyListeners();
    } catch (e) {
      print('Erreur réinitialisation préférences: $e');
    }
  }

  // Getters pour les labels UI
  String get themeModeLabel {
    switch (_themeMode) {
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.system:
        return 'Système';
    }
  }

  String get themeModeDescription {
    switch (_themeMode) {
      case ThemeMode.dark:
        return 'Interface sombre artistique';
      case ThemeMode.light:
        return 'Interface claire élégante';
      case ThemeMode.system:
        return 'Suivi des préférences système';
    }
  }

  IconData get themeModeIcon {
    switch (_themeMode) {
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }
}