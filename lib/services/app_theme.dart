import 'package:flutter/material.dart';

class AppTheme {

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: const Color.fromARGB(255, 42, 46, 76),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 42, 46, 76),
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    drawerTheme: const DrawerThemeData(
      backgroundColor: Color.fromARGB(255, 42, 46, 76),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 42, 46, 76),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
    ),

    cardColor: const Color.fromARGB(255, 60, 64, 93),

    dividerColor: Colors.white24,
  );

 
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,

    scaffoldBackgroundColor: const Color(0xFFF4F5F7),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),

    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
    ),

    cardColor: Colors.white,

    dividerColor: Colors.black12,
  );
}
