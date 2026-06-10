import 'dart:io';
import 'package:flutter/material.dart';

class ThemeService {
  // Map of Yaru color names to Flutter Colors
  static final Map<String, Color> _colorMap = {
    'blue': Colors.blue,
    'red': Colors.red,
    'green': Colors.green,
    'yellow': Colors.yellow,
    'purple': Colors.purple,
    'orange': Colors.orange,
    'pink': Colors.pink,
    'teal': Colors.teal,
    'cyan': Colors.cyan,
    'indigo': Colors.indigo,
    'lime': Colors.lime,
    'amber': Colors.amber,
    'brown': Colors.brown,
    'grey': Colors.grey,
    'gray': Colors.grey,
    'magenta': Colors.deepPurple,
    'sage': Colors.green,
    'olive': Colors.green,
  };

  /// Get the current Omarchy theme color
  /// Returns Colors.blue as fallback for any errors
  static Future<Color> getOmarchyThemeColor() async {
    try {
      final homeDir = Platform.environment['HOME'];
      if (homeDir == null) {
        return Colors.blue;
      }

      String? content;

      // 1. Try reading the active theme's icons.theme directly
      final directThemePath = '$homeDir/.config/omarchy/current/theme/icons.theme';
      final directThemeFile = File(directThemePath);
      
      if (await directThemeFile.exists()) {
        content = await directThemeFile.readAsString();
      }

      // 2. If that fails, read theme.name config to locate the theme folder
      if (content == null) {
        final themeNameFile = File('$homeDir/.config/omarchy/current/theme.name');
        String themeName = '';
        if (await themeNameFile.exists()) {
          themeName = (await themeNameFile.readAsString()).trim().toLowerCase().replaceAll(' ', '-');
        } else {
          // Fallback: Execute omarchy-theme-current command as last resort
          final result = await Process.run('omarchy-theme-current', []);
          if (result.exitCode == 0) {
            themeName = result.stdout.toString().trim().toLowerCase().replaceAll(' ', '-');
          }
        }

        if (themeName.isNotEmpty) {
          final themeFilePath = '$homeDir/.config/omarchy/themes/$themeName/icons.theme';
          final themeFile = File(themeFilePath);
          if (await themeFile.exists()) {
            content = await themeFile.readAsString();
          }
        }
      }

      if (content == null) {
        return Colors.blue;
      }

      // Parse the content to find Yaru color variant
      // Looking for patterns like "Yaru-blue", "Yaru-red", etc.
      final yaruRegex = RegExp(r'Yaru-(\w+)', caseSensitive: false);
      final match = yaruRegex.firstMatch(content);

      if (match == null) {
        return Colors.blue;
      }

      // Extract the color part (e.g., "blue" from "Yaru-blue")
      final colorName = match.group(1)?.toLowerCase();
      
      if (colorName == null) {
        return Colors.blue;
      }

      // Map the color name to Flutter Color
      return _colorMap[colorName] ?? Colors.blue;

    } catch (e) {
      // Any error (command not found, file errors, etc.) returns blue
      return Colors.blue;
    }
  }
}

