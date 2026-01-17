import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color red = Color(0xFFf72530);
  static const Color white = Color(0xFFFFFFFF);
  static const Color blue = Color(0xFF2475FF);
  static const Color green = Color(0xFF32cd32);
  static const Color grey = Color(0xFFC8C9CB);
  static const Color black = Color(0xFF060E1E);
  static const Color purple = Color(0xFF9370db);
  static const Color background = Color(0xFFFAFAFA);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: background,
    primaryColor: white,
    
    appBarTheme: const AppBarTheme(
      foregroundColor: white,
      elevation: 3,
      backgroundColor: white,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: black,
      ),
      iconTheme: IconThemeData(color: black),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: Color(0xFFF5F5F5),
        foregroundColor: black,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(fontSize: 14),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: red,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    iconTheme: const IconThemeData(color: black),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: white,
      selectedItemColor: blue,
      unselectedItemColor: grey,
      elevation: 8,
    ),
    
    textTheme: const TextTheme(
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: black,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: black,
      ),
    ),
  );
}