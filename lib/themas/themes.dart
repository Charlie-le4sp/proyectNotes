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
    applyElevationOverlayColor: false,
    useMaterial3: true,

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 16,
        height: 1.5,
      ),
      titleLarge: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
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
    tabBarTheme: TabBarTheme(
      labelColor: Colors.black,
      indicatorSize: TabBarIndicatorSize.tab,
      unselectedLabelColor: Colors.grey,
      indicator: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(50),
          color: Colors.transparent),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(250, 243, 224, 93),
    ),
    primaryColor: Colors.blue,

    useMaterial3: true,
    scaffoldBackgroundColor:
        Color.fromARGB(250, 243, 224, 93), // Color papel antiguo

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
  );

  // Tema Noche Azulada
  static ThemeData blueNightTheme = ThemeData(
    scaffoldBackgroundColor: Color.fromARGB(255, 33, 24, 73),
    appBarTheme: const AppBarTheme(
      titleTextStyle: TextStyle(color: Colors.white),
      backgroundColor: Colors.transparent,
    ),
    tabBarTheme: TabBarTheme(
      unselectedLabelColor: const Color.fromARGB(255, 215, 215, 215),
      indicator: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(50),
          color: Colors.transparent),
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
    useMaterial3: true,
  );
}
