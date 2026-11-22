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
    'Cursive': 'El Yazısı',
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

/// Bir not renginin kart tasarımı: kağıt (zemin), mürekkep (çerçeve/etiket) ve simge.
class NoteCardStyle {
  final Color paper;
  final Color ink;
  final IconData icon;
  final String label;

  const NoteCardStyle(this.paper, this.ink, this.icon, this.label);

  /// Kağıdın açık ve koyu tonları (hafif degrade için).
  Color get paperLight => Color.lerp(paper, Colors.white, 0.35)!;
  Color get paperDark => Color.lerp(paper, ink, 0.08)!;

  /// Kart üstündeki ana yazı rengi: mürekkebin çok koyu hali, okunurluk için.
  Color get text => Color.lerp(ink, Colors.black, 0.6)!;
}

class NoteColor {
  static const Map<String, NoteCardStyle> styles = {
    'default': NoteCardStyle(Color(0xFFE8CCBD), Color(0xFF4E342E), Icons.auto_stories_outlined, 'Klasik'),
    'yellow': NoteCardStyle(Color(0xFFFFE9A0), Color(0xFF7A5900), Icons.lightbulb_outline, 'Fikir'),
    'pink': NoteCardStyle(Color(0xFFF8C6D6), Color(0xFF8E2450), Icons.favorite_border, 'Sevgi'),
    'blue': NoteCardStyle(Color(0xFFC4DCF5), Color(0xFF1D4E89), Icons.school_outlined, 'Okul'),
    'green': NoteCardStyle(Color(0xFFCDE8C4), Color(0xFF2D6A33), Icons.eco_outlined, 'Doğa'),
    'orange': NoteCardStyle(Color(0xFFFFD1A6), Color(0xFF9A4600), Icons.local_fire_department_outlined, 'Önemli'),
    'purple': NoteCardStyle(Color(0xFFDFCAF0), Color(0xFF5B3290), Icons.auto_awesome_outlined, 'Hayal'),
  };

  /// Geriye dönük uyumluluk: rengin kağıt tonu.
  static Map<String, Color> get colors => styles.map((k, v) => MapEntry(k, v.paper));

  /// Klasik kartın yazı rengi (eski kodlar için).
  static const Color cardTextColor = Color(0xDD000000);

  static List<String> get colorNames => styles.keys.toList();

  static NoteCardStyle style(String? colorName) => styles[colorName] ?? styles['default']!;

  static Color getColor(String colorName) => style(colorName).paper;

  static String getColorName(Color color) {
    for (final entry in styles.entries) {
      if (entry.value.paper == color) return entry.key;
    }
    return 'default';
  }

  static String getLocalizedName(String colorName) => style(colorName).label;
}
