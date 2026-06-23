import 'package:flutter/material.dart';

class SubscriptionPlan {
  final int id;
  final String name;
  final String description;
  final double price;
  final int durationDays;
  final int durationMonths;
  final String planSessionYear;
  final List<String> features;
  final List<bool> featureIncluded;
  final String? badgeLabel;
  final bool isFeatured;
  final int sortOrder;
  final String promoCode;
  final String promoText;
  final String planTitle;
  final bool recommended;
  final String termsLink;
  final String boxColor;
  final String boxBorderColor;
  final String textColor;
  final String planIcon;

  SubscriptionPlan({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    this.durationDays = 0,
    this.durationMonths = 0,
    this.planSessionYear = '',
    this.features = const [],
    this.featureIncluded = const [],
    this.badgeLabel,
    this.isFeatured = false,
    this.sortOrder = 0,
    this.promoCode = '',
    this.promoText = '',
    this.planTitle = '',
    this.recommended = false,
    this.termsLink = '',
    this.boxColor = '',
    this.boxBorderColor = '',
    this.textColor = '',
    this.planIcon = 'crown',
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    // Parse features
    List<String> featuresList = [];
    if (json['features'] is List) {
      featuresList = (json['features'] as List)
          .map((f) => f.toString())
          .toList();
    } else if (json['features'] is String) {
      featuresList = (json['features'] as String)
          .split('\n')
          .where((f) => f.trim().isNotEmpty)
          .toList();
    }

    // Parse feature_included
    List<bool> includedList = [];
    if (json['feature_included'] is List) {
      includedList = (json['feature_included'] as List).map((f) {
        if (f is bool) return f;
        return f == 1 || f == true || f == 'true';
      }).toList();
    }
    // Default all features to included if no data
    if (includedList.isEmpty) {
      includedList = List.filled(featuresList.length, true);
    }
    // Ensure lists are same length
    while (includedList.length < featuresList.length) {
      includedList.add(true);
    }

    return SubscriptionPlan(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationDays: json['duration_days'] as int? ?? 0,
      durationMonths: json['duration_months'] as int? ?? 0,
      planSessionYear: json['plan_session_year'] as String? ?? '',
      features: featuresList,
      featureIncluded: includedList,
      badgeLabel: json['badge_label'] as String?,
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
      sortOrder: json['sort_order'] as int? ?? 0,
      promoCode: json['promo_code'] as String? ?? '',
      promoText: json['promo_text'] as String? ?? '',
      planTitle: json['plan_title'] as String? ?? '',
      recommended: json['recommended'] == true || json['recommended'] == 1,
      termsLink: json['terms_link'] as String? ?? '',
      boxColor: json['box_color'] as String? ?? '',
      boxBorderColor: json['box_border_color'] as String? ?? '',
      textColor: json['text_color'] as String? ?? '',
      planIcon: json['plan_icon'] as String? ?? 'crown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration_days': durationDays,
      'duration_months': durationMonths,
      'plan_session_year': planSessionYear,
      'features': features,
      'feature_included': featureIncluded,
      'badge_label': badgeLabel,
      'is_featured': isFeatured,
      'sort_order': sortOrder,
      'promo_code': promoCode,
      'promo_text': promoText,
      'plan_title': planTitle,
      'recommended': recommended,
      'terms_link': termsLink,
      'box_color': boxColor,
      'box_border_color': boxBorderColor,
      'text_color': textColor,
      'plan_icon': planIcon,
    };
  }

  /// Get duration as a human-readable label
  String get durationLabel {
    if (durationMonths > 0) {
      return '$durationMonths Month${durationMonths > 1 ? 's' : ''}';
    }
    if (durationDays > 0) {
      return '$durationDays Days';
    }
    return 'N/A';
  }

  /// Parse hex color string to Color
  Color getBoxColor() {
    return _parseColor(boxColor, const Color(0xFFF5F5F5));
  }

  Color getBorderColor() {
    return _parseColor(boxBorderColor, const Color(0xFFDEE2E6));
  }

  Color getTextColor() {
    return _parseColor(textColor, const Color(0xFF212529));
  }

  static Color _parseColor(String hex, Color fallback) {
    if (hex.isEmpty) return fallback;
    try {
      hex = hex.replaceFirst('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}
