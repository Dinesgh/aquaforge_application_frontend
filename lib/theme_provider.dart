import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, custom }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _mode = AppThemeMode.light;
  Color _primaryColor = Colors.blue;
  Color _accentColor = Colors.amber;

  AppThemeMode get mode => _mode;
  Color get primaryColor => _primaryColor;
  Color get accentColor => _accentColor;

  ThemeData get themeData {
    switch (_mode) {
      case AppThemeMode.dark:
        return ThemeData.dark().copyWith(
          primaryColor: _primaryColor,
          colorScheme: ThemeData.dark().colorScheme.copyWith(
            primary: _primaryColor,
            secondary: _accentColor,
          ),
        );
      case AppThemeMode.custom:
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: _primaryColor,
          colorScheme: ColorScheme.light(
            primary: _primaryColor,
            secondary: _accentColor,
          ),
        );
      case AppThemeMode.light:
      default:
        return ThemeData.light().copyWith(
          primaryColor: _primaryColor,
          colorScheme: ThemeData.light().colorScheme.copyWith(
            primary: _primaryColor,
            secondary: _accentColor,
          ),
        );
    }
  }

  void setThemeMode(AppThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void setCustomColors(Color primary, Color accent) {
    _primaryColor = primary;
    _accentColor = accent;
    _mode = AppThemeMode.custom;
    notifyListeners();
  }
}
