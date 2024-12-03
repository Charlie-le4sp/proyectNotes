import 'package:flutter/material.dart';

class Themes {
  // ignore: constant_identifier_names
  static const double APPBAR_ELEVATION = 0;

  //MODO CLARO____________________________
  static ThemeData lightTheme = ThemeData(
    appBarTheme: const AppBarTheme(
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0, // Puedes ajustar la elevación si lo deseas
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(Colors.transparent),
      trackColor: WidgetStateProperty.all(Colors.transparent),
      trackBorderColor: WidgetStateProperty.all(Colors.transparent),
    ),
    useMaterial3: true,
    primaryColor: Colors.blue,
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: const Color.fromARGB(255, 144, 79, 255),
      labelTextStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(fontSize: 12.5, fontFamily: "Poppins")),
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
    ),
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
    colorScheme: const ColorScheme.light(surface: Colors.white)
        .copyWith(secondary: const Color.fromARGB(255, 0, 22, 43)),
    splashFactory: NoSplash.splashFactory, // Deshabilitar ripple
    highlightColor: Colors.transparent, // Eliminar highlight
  );

  //MODO OSCURO____________________________
  static ThemeData darkTheme = ThemeData(
    appBarTheme: const AppBarTheme(
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
    ),
    applyElevationOverlayColor: false,
    useMaterial3: true,
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(Colors.transparent),
      trackColor: WidgetStateProperty.all(Colors.transparent),
      trackBorderColor: WidgetStateProperty.all(Colors.transparent),
    ),
    navigationBarTheme: NavigationBarThemeData(
      surfaceTintColor: Colors.transparent,
      indicatorColor: const Color.fromARGB(255, 124, 57, 240),
      backgroundColor: const Color.fromARGB(255, 0, 13, 24),
      labelTextStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(fontSize: 12.5, fontFamily: "Poppins")),
    ),
    brightness: Brightness.dark,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: const Color.fromARGB(255, 0, 5, 9),
    colorScheme: const ColorScheme.dark(surface: Colors.transparent),
    splashFactory: NoSplash.splashFactory, // Deshabilitar ripple
    highlightColor: Colors.transparent, // Eliminar highlight
  );

  // Tema Cuaderno
  static ThemeData notebookTheme = ThemeData(
    primaryColor: Colors.blue,
    useMaterial3: true,
    scaffoldBackgroundColor:
        Color.fromARGB(255, 215, 215, 93), // Color papel antiguo
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 227, 227, 101),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.black87,
        fontSize: 16,
        height: 1.5,
      ),
      titleLarge: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white.withOpacity(0.9),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black12),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFFF5F5DC),
      indicatorColor: Colors.brown.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.all(
        const TextStyle(fontSize: 12.5, fontFamily: "Poppins"),
      ),
    ),
  );

  // Tema Noche Azulada
  static ThemeData blueNightTheme = ThemeData(
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.black87,
        fontSize: 16,
        height: 1.5,
      ),
      titleLarge: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Color.fromARGB(255, 78, 64, 20),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A1929),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFE3F2FD)),
      titleTextStyle: TextStyle(
        color: Color(0xFFE3F2FD),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF64B5F6),
      secondary: Color(0xFF90CAF9),
      surface: Color(0xFF0D2137),
      background: Color(0xFF0A1929),
    ),
    cardTheme: CardTheme(
      color: Color.fromARGB(255, 13, 55, 19),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF0A1929),
      indicatorColor: const Color(0xFF64B5F6).withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.all(
        const TextStyle(fontSize: 12.5, fontFamily: "Poppins"),
      ),
    ),
  );
}
