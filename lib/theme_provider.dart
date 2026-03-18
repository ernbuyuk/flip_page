import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeController {
  static const String _themePreferenceKey = 'isDarkMode';
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  static bool get isDarkMode => themeMode.value == ThemeMode.dark;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themePreferenceKey) ?? false;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> setDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePreferenceKey, isDarkMode);
    themeMode.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}

class AppFontSettings {
  static const String _fontPreferenceKey = 'labelFontFamily';
  static const String defaultFontFamily = 'Cursive';

  static const Map<String, String> availableFonts = {
    'Cursive': 'El Yazisi (Cursive)',
    'Roboto': 'Roboto',
    'serif': 'Serif',
    'sans-serif': 'Sans Serif',
  };

  static String _labelFontFamily = defaultFontFamily;

  static String get labelFontFamily => _labelFontFamily;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _labelFontFamily = prefs.getString(_fontPreferenceKey) ?? defaultFontFamily;
  }

  static Future<void> save(String fontFamily) async {
    _labelFontFamily = fontFamily;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontPreferenceKey, fontFamily);
  }
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    await AppThemeController.load();
    _isDarkMode = AppThemeController.isDarkMode;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await AppThemeController.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.brown,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Color(0xFFF5F0EB),
      cardColor: Colors.white,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.brown,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(0xFF2C2622),
      cardColor: Color(0xFF3A332D),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
    );
  }

  Color getBackgroundColor() {
    return _isDarkMode ? Color(0xFF2C2622) : Color(0xFFF5F0EB);
  }

  Color getCardColor() {
    return _isDarkMode ? Color(0xFF3A332D) : Colors.white;
  }

  Color getTextColor() {
    return _isDarkMode ? Colors.white : Colors.black;
  }

  Color getSecondaryTextColor() {
    return _isDarkMode ? Colors.white70 : Colors.black87;
  }
}

class NoteColor {
  static const Map<String, Color> colors = {
    'default': Colors.white,
    'yellow': Color(0xFFFFF9C4),
    'pink': Color(0xFFF8BBD0),
    'blue': Color(0xFFBBDEFB),
    'green': Color(0xFFC8E6C9),
    'orange': Color(0xFFFFE0B2),
    'purple': Color(0xFFE1BEE7),
  };

  static List<String> get colorNames => colors.keys.toList();

  static Color getColor(String colorName) {
    return colors[colorName] ?? colors['default']!;
  }

  static String getColorName(Color color) {
    for (var entry in colors.entries) {
      if (entry.value == color) {
        return entry.key;
      }
    }
    return 'default';
  }

  static String getLocalizedName(String colorName) {
    switch (colorName) {
      case 'default':
        return 'Varsayılan';
      case 'yellow':
        return 'Sarı';
      case 'pink':
        return 'Pembe';
      case 'blue':
        return 'Mavi';
      case 'green':
        return 'Yeşil';
      case 'orange':
        return 'Turuncu';
      case 'purple':
        return 'Mor';
      default:
        return 'Varsayılan';
    }
  }
}
