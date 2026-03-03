import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

final lightTheme = ThemeData(
  brightness: Brightness.light,
  colorSchemeSeed: Colors.green,
  useMaterial3: true,
  cardTheme: CardThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorSchemeSeed: Colors.green,
  useMaterial3: true,
  cardTheme: CardThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
  ),
);
