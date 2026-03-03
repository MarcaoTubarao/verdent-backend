import 'package:flutter/material.dart';
import 'app.dart';
import 'theme.dart';

final themeProvider = ThemeProvider();

void main() {
  runApp(
    AnimatedBuilder(
      animation: themeProvider,
      builder: (context, _) => BolsaBBBApp(themeProvider: themeProvider),
    ),
  );
}
