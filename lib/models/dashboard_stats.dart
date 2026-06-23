class DashboardStats {
  final int todayOrders;
  final int pendingOrders;
  final int completedOrders;
  final double todayRevenue;
  final double monthRevenue;
  final double yearRevenue;
  final int totalProducts;
  final int lowStockProducts;
  final int totalReviews;
  final double averageRating;
  final List<SalesData>? recentSales;

  // Additional properties for new dashboard
  final int totalOrders;
  final double totalRevenue;

  DashboardStats({
    this.todayOrders = 0,
    this.pendingOrders = 0,
    this.completedOrders = 0,
    this.todayRevenue = 0,
    this.monthRevenue = 0,
    this.yearRevenue = 0,
    this.totalProducts = 0,
    this.lowStockProducts = 0,
    this.totalReviews = 0,
    this.averageRating = 0,
    this.recentSales,
    this.totalOrders = 0,
    this.totalRevenue = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      todayOrders: json['today_orders'] as int? ?? 0,
      pendingOrders: json['pending_orders'] as int? ?? 0,
      completedOrders: json['completed_orders'] as int? ?? 0,
      todayRevenue: double.parse(json['today_revenue']?.toString() ?? '0'),
      monthRevenue: double.parse(json['month_revenue']?.toString() ?? '0'),
      yearRevenue: double.parse(json['year_revenue']?.toString() ?? '0'),
      totalProducts: json['total_products'] as int? ?? 0,
      lowStockProducts: json['low_stock_products'] as int? ?? 0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      averageRating: double.parse(json['average_rating']?.toString() ?? '0'),
      recentSales: json['recent_sales'] != null
          ? (json['recent_sales'] as List)
                .map((sale) => SalesData.fromJson(sale))
                .toList()
          : null,
      totalOrders: json['total_orders'] as int? ?? 0,
      totalRevenue: double.parse(json['total_revenue']?.toString() ?? '0'),
    );
  }
}

class SalesData {
  final String date;
  final double amount;
  final int orders;

  SalesData({required this.date, required this.amount, required this.orders});

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      date: json['date'] as String,
      amount: double.parse(json['amount']?.toString() ?? '0'),
      orders: json['orders'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'amount': amount, 'orders': orders};
  }
}

class AppNotification {
  final int id;
  final String title;
  final String message;
  final String? type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.type,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
