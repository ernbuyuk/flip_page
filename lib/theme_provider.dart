import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
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
      scaffoldBackgroundColor: Color(0xFF1A1A1A),
      cardColor: Color(0xFF2A2A2A),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
    );
  }

  Color getBackgroundColor() {
    return _isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFF5F0EB);
  }

  Color getCardColor() {
    return _isDarkMode ? Color(0xFF2A2A2A) : Colors.white;
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
