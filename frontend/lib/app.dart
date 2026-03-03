import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'theme.dart';

class BolsaBBBApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  const BolsaBBBApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BolsaBBB',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: DashboardScreen(themeProvider: themeProvider),
    );
  }
}
