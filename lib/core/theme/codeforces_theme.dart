import 'package:flutter/material.dart';

class CodeforcesTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF3366CC),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF0F0F0),
        foregroundColor: Colors.black87,
        elevation: 1,
        centerTitle: false,
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF3366CC),
        secondary: Color(0xFF0000EE),
        surface: Colors.white,
        onSurface: Colors.black87,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFCCCCCC), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      dividerColor: const Color(0xFFCCCCCC),
      fontFamily: 'Roboto', // Codeforces typically uses standard sans-serif
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF4DB8FF),
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4DB8FF),
        secondary: Color(0xFF66B2FF),
        surface: Color(0xFF252526),
        onSurface: Colors.white, // Increased contrast from #CCCCCC
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF252526),
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF444444), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      dividerColor: const Color(0xFF444444),
      fontFamily: 'Roboto',
    );
  }
}
