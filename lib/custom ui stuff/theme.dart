import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

  final ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF419B9E),
    secondaryHeaderColor: const Color(0xFF419B9E),
    scaffoldBackgroundColor: const Color.fromARGB(255, 121, 192, 160),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF40A578),
      foregroundColor: Colors.white,
    ),
    canvasColor: const Color.fromARGB(255, 121, 192, 160),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
      bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
      labelLarge: TextStyle(fontSize: 16.0, color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF40A578)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey.withOpacity(0.5), width: 0.5),
      ),
    ),
  );




final ThemeData darkTheme = ThemeData(
  primaryColor: const Color(0xFF419B9E),
  secondaryHeaderColor: const Color(0xFF102E23),
  scaffoldBackgroundColor: const Color(0xFF121212), // Darker background for better contrast
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF102E23), // Darker variant for app bar
    foregroundColor: Colors.white,
    elevation: 1, // Slight elevation for depth
    iconTheme: IconThemeData(color: Colors.white),
  ),
  canvasColor: const Color(0xFF1E1E1E), // Consistent with app bar
  textTheme: const TextTheme(
    headlineSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white), // Better contrast
    labelLarge: TextStyle(fontSize: 16.0, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white70),
    bodySmall: TextStyle(fontSize: 12.0, color: Colors.white54), // Slightly lighter for readability
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF40A578)), // Consistent with light theme
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Ensuring text is readable
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  ),
  cardTheme: CardTheme(
    color: const Color(0xFF1F1F1F), // Darker but consistent with light theme
    elevation: 3.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      side: BorderSide(color: Colors.white24.withOpacity(0.5), width: 0.5),
    ),
  ),
  dividerColor: Colors.white24, // Subtle dividers for better separation
);