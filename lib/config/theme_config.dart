import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Theme Configuration for Gas Lagbe Vendor App
class ThemeConfig {
  // ==================== COLOR PALETTE ====================

  // Primary Brand Colors
  static const Color primaryBlue = Color(0xFF5B6EF5); // Gas Lagbe brand blue
  static const Color darkBlue = Color(0xFF001B44); // Dark navy for buttons

  // Accent Colors
  static const Color orange = Color(0xFFFF9245); // CTAs and highlights
  static const Color pink = Color(0xFFE961FF); // Pending orders
  static const Color teal = Color(0xFF4FDDC5); // Ratings and success
  static const Color lime = Color(0xFFD4FF4D); // Shop status background
  static const Color purple = Color(0xFF8B7BF7); // Total orders card

  // Status Colors
  static const Color statusPending = Color(0xFFFF9245); // Orange
  static const Color statusAccepted = Color(0xFF5B6EF5); // Blue
  static const Color statusProcessing = Color(0xFFE961FF); // Pink
  static const Color statusDelivered = Color(0xFF10B981); // Green
  static const Color statusDeclined = Color(0xFFEF4444); // Red

  // Neutral Colors
  static const Color backgroundColor = Color(0xFFFAFAFA); // Light gray
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color borderColor = Color(0xFFE5E7EB);

  // Stock Indicators
  static const Color inStock = Color(0xFF10B981); // Green
  static const Color outOfStock = Color(0xFFEF4444); // Red

  // ==================== BACKWARD COMPATIBILITY ====================
  // Legacy color properties for backward compatibility with old UI code

  static Color get primaryColor => primaryBlue;
  static Color get secondaryColor => purple;
  static Color get successColor => statusDelivered; // Green
  static Color get errorColor => statusDeclined; // Red
  static Color get warningColor => orange; // Orange
  static Color get infoColor => teal; // Teal

  // Legacy gradient colors
  static Color get primaryStart => primaryBlue;
  static Color get secondaryStart => purple;

  // Glass morphism decoration helper
  static BoxDecoration glassDecoration({
    Color? color,
    double? borderRadius,
    double? opacity,
  }) {
    return BoxDecoration(
      color: (color ?? cardWhite).withValues(alpha: opacity ?? 0.9),
      borderRadius: BorderRadius.circular(borderRadius ?? radiusMedium),
      border: Border.all(color: borderColor.withValues(alpha: 0.2), width: 1),
      boxShadow: cardShadow,
    );
  }

  // ==================== GRADIENTS ====================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF4A5FE8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBlueGradient = LinearGradient(
    colors: [darkBlue, Color(0xFF002855)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subscriptionGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== SHADOWS ====================

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: primaryBlue.withValues(alpha: 0.2),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: darkBlue.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // ==================== BORDER RADIUS ====================

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusPill = 100.0;
  static const double radiusFull = 100.0; // Alias for radiusPill

  // ==================== SPACING ====================

  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 12.0;
  static const double spaceLG = 16.0;
  static const double spaceXL = 24.0;
  static const double space2XL = 32.0;
  static const double space3XL = 48.0;

  // ==================== TYPOGRAPHY ====================

  static TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.3,
  );

  static TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.3,
  );

  static TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textLight,
    height: 1.4,
  );

  static TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  static TextStyle labelText = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.4,
  );

  static TextStyle captionText = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: textLight,
    height: 1.3,
  );

  // Large numbers for metrics
  static TextStyle metricValue = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.2,
  );

  static TextStyle metricLabel = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white.withValues(alpha: 0.9),
    height: 1.3,
  );

  // ==================== THEME DATA ====================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: GoogleFonts.poppins().fontFamily,

      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: orange,
        surface: cardWhite,
        error: statusDeclined,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: cardWhite,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: heading3,
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: spaceLG,
          vertical: spaceSM,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceXL,
            vertical: spaceLG,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          elevation: 0,
          textStyle: buttonText,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderColor, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: spaceXL,
            vertical: spaceLG,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: statusDeclined),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceLG,
          vertical: spaceLG,
        ),
        hintStyle: bodyMedium.copyWith(color: textLight),
        labelStyle: labelText,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textLight,
        selectedLabelStyle: captionText.copyWith(
          color: primaryBlue,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: captionText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  /// Get status color based on order status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'accepted':
        return statusAccepted;
      case 'processing':
        return statusProcessing;
      case 'delivered':
        return statusDelivered;
      case 'declined':
      case 'cancelled':
        return statusDeclined;
      default:
        return textSecondary;
    }
  }

  /// Get status background color (lighter version)
  static Color getStatusBackgroundColor(String status) {
    return getStatusColor(status).withValues(alpha: 0.1);
  }

  /// Create metric card decoration with specific color
  static BoxDecoration metricCardDecoration(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radiusLarge),
      boxShadow: cardShadow,
    );
  }

  /// Create button decoration with gradient
  static BoxDecoration buttonDecoration({Gradient? gradient, Color? color}) {
    return BoxDecoration(
      gradient: gradient,
      color: color,
      borderRadius: BorderRadius.circular(radiusMedium),
      boxShadow: buttonShadow,
    );
  }
}
