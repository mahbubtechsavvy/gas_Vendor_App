class AnalyticsData {
  final List<RevenueTrend> revenueTrend;
  final KeyMetrics keyMetrics;
  final SalesPerformance salesPerformance;

  AnalyticsData({
    required this.revenueTrend,
    required this.keyMetrics,
    required this.salesPerformance,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      revenueTrend:
          (json['revenue_trend'] as List?)
              ?.map((e) => RevenueTrend.fromJson(e))
              .toList() ??
          [],
      keyMetrics: KeyMetrics.fromJson(json['key_metrics'] ?? {}),
      salesPerformance: SalesPerformance.fromJson(
        json['sales_performance'] ?? {},
      ),
    );
  }
}

class RevenueTrend {
  final String month;
  final double revenue;

  RevenueTrend({required this.month, required this.revenue});

  factory RevenueTrend.fromJson(Map<String, dynamic> json) {
    return RevenueTrend(
      month: json['month'] ?? '',
      revenue: double.tryParse(json['revenue'].toString()) ?? 0.0,
    );
  }
}

class KeyMetrics {
  final int totalOrders;
  final String totalOrdersChange;
  final double avgOrderValue;
  final String avgOrderValueChange;
  final double deliverySuccess;
  final String deliverySuccessChange;
  final int cancelledOrders;
  final String cancelledOrdersChange;

  KeyMetrics({
    required this.totalOrders,
    required this.totalOrdersChange,
    required this.avgOrderValue,
    required this.avgOrderValueChange,
    required this.deliverySuccess,
    required this.deliverySuccessChange,
    required this.cancelledOrders,
    required this.cancelledOrdersChange,
  });

  factory KeyMetrics.fromJson(Map<String, dynamic> json) {
    return KeyMetrics(
      totalOrders: json['total_orders'] ?? 0,
      totalOrdersChange: json['total_orders_change'] ?? '0%',
      avgOrderValue: double.tryParse(json['avg_order_value'].toString()) ?? 0.0,
      avgOrderValueChange: json['avg_order_value_change'] ?? '0%',
      deliverySuccess:
          double.tryParse(json['delivery_success'].toString()) ?? 0.0,
      deliverySuccessChange: json['delivery_success_change'] ?? '0%',
      cancelledOrders: json['cancelled_orders'] ?? 0,
      cancelledOrdersChange: json['cancelled_orders_change'] ?? '0%',
    );
  }
}

class SalesPerformance {
  final double conversionRate;
  final double repeatRate;

  SalesPerformance({required this.conversionRate, required this.repeatRate});

  factory SalesPerformance.fromJson(Map<String, dynamic> json) {
    return SalesPerformance(
      conversionRate:
          double.tryParse(json['conversion_rate'].toString()) ?? 0.0,
      repeatRate: double.tryParse(json['repeat_rate'].toString()) ?? 0.0,
    );
  }
}
