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
    scaffoldBackgroundColor: Colors.white,
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
}
