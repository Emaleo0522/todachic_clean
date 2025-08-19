import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFE91E63);
  static const Color secondaryColor = Color(0xFF9C27B0);
  static const Color tertiaryColor = Color(0xFF3F51B5);
  
  static const Color accentColor = Color(0xFFFF5722);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Colors.white;
  
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
    );
  }
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
    ],
  );

  static const LinearGradient appBar = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.tertiaryColor,
    ],
  );

  static const LinearGradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white,
      Color(0xFFF5F5F5),
    ],
  );

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppTheme.accentColor,
      Colors.deepOrange,
    ],
  );
}

class AppSizes {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;
  static const double iconSize = 24.0;
}

class AppSpacing {
  // Spacing constants for consistent layout
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // Card spacing
  static const double cardPadding = 16.0;
  static const double cardMargin = 8.0;
  static const double cardBorderRadius = 12.0;
  
  // List item spacing
  static const double listItemPadding = 12.0;
  static const double listItemSpacing = 8.0;
  
  // Form spacing
  static const double formFieldSpacing = 16.0;
  static const double formSectionSpacing = 24.0;
  
  // Screen margins
  static const double screenHorizontal = 16.0;
  static const double screenVertical = 20.0;
}

class AppDurations {
  // Animation durations for consistent timing
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 800);
  
  // Specific animations
  static const Duration cardAnimation = Duration(milliseconds: 200);
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration modalAnimation = Duration(milliseconds: 250);
  static const Duration fadeAnimation = Duration(milliseconds: 400);
  static const Duration slideAnimation = Duration(milliseconds: 300);
  static const Duration scaleAnimation = Duration(milliseconds: 200);
  
  // Loading and feedback
  static const Duration loading = Duration(milliseconds: 1000);
  static const Duration snackBar = Duration(seconds: 3);
  static const Duration splash = Duration(seconds: 2);
}

class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppTheme.primaryColor,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.black45,
  );
}