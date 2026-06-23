import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../config/app_config.dart';
import '../../models/analytics_data.dart';
import '../../providers/auth_provider.dart';
import '../../services/analytics_service.dart';

class BusinessAnalyticsScreen extends StatefulWidget {
  const BusinessAnalyticsScreen({super.key});

  @override
  State<BusinessAnalyticsScreen> createState() =>
      _BusinessAnalyticsScreenState();
}

class _BusinessAnalyticsScreenState extends State<BusinessAnalyticsScreen> {
  String _selectedPeriod = 'Last 30 Days';
  AnalyticsData? _analyticsData;
  bool _isLoading = true;
  String? _error;

  final List<String> _periods = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 90 Days',
    'This Year',
  ];

  final Map<String, int> _periodRanges = {
    'Last 7 Days': 7,
    'Last 30 Days': 30,
    'Last 90 Days': 90,
    'This Year': 365,
  };

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = context.read<AuthProvider>().token ?? '';
      final range = _periodRanges[_selectedPeriod] ?? 30;
      final data = await AnalyticsService.getAnalytics(token, range: range);

      if (!mounted) return;
      setState(() {
        _analyticsData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onPeriodChanged(String? period) {
    if (period == null || period == _selectedPeriod) return;
    setState(() => _selectedPeriod = period);
    _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeConfig.cardWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Business Analytics', style: ThemeConfig.heading3),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _analyticsData == null
                  ? _buildEmptyState()
                  : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spaceXL),
        child: Card(
          color: ThemeConfig.cardWhite,
          child: Padding(
            padding: const EdgeInsets.all(ThemeConfig.spaceXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: ThemeConfig.errorColor, size: 48),
                const SizedBox(height: ThemeConfig.spaceLG),
                Text('Could not load analytics', style: ThemeConfig.heading3),
                const SizedBox(height: ThemeConfig.spaceSM),
                Text(
                  _error ?? 'Unknown error',
                  style: ThemeConfig.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ThemeConfig.spaceLG),
                ElevatedButton.icon(
                  onPressed: _loadAnalytics,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spaceXL),
        child: Card(
          color: ThemeConfig.cardWhite,
          child: Padding(
            padding: const EdgeInsets.all(ThemeConfig.spaceXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.analytics_outlined, color: ThemeConfig.textSecondary, size: 48),
                const SizedBox(height: ThemeConfig.spaceLG),
                Text('No analytics data available', style: ThemeConfig.heading3),
                const SizedBox(height: ThemeConfig.spaceSM),
                Text(
                  'Try another period or check back after more orders are delivered.',
                  style: ThemeConfig.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final analytics = _analyticsData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeConfig.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),

          const SizedBox(height: ThemeConfig.spaceXL),

          Container(
            padding: const EdgeInsets.all(ThemeConfig.spaceXL),
            decoration: BoxDecoration(
              color: ThemeConfig.cardWhite,
              borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
              boxShadow: ThemeConfig.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Revenue Trend', style: ThemeConfig.heading3),
                const SizedBox(height: 4),
                Text(
                  'Gross revenue from delivered orders',
                  style: ThemeConfig.bodySmall.copyWith(
                    color: ThemeConfig.textLight,
                  ),
                ),
                const SizedBox(height: ThemeConfig.spaceXL),
                SizedBox(
                  height: 200,
                  child: analytics.revenueTrend.isEmpty
                      ? const Center(
                          child: Text(
                            'No revenue data for this period',
                            style: TextStyle(color: ThemeConfig.textSecondary),
                          ),
                        )
                      : LineChart(_buildLineChartData(analytics)),
                ),
              ],
            ),
          ),

          const SizedBox(height: ThemeConfig.spaceXL),

          Text('Key Metrics', style: ThemeConfig.heading3),
          const SizedBox(height: ThemeConfig.spaceLG),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: ThemeConfig.spaceMD,
            crossAxisSpacing: ThemeConfig.spaceMD,
            childAspectRatio: 1.1,
            children: [
              _buildMetricCard(
                title: 'Total Orders',
                value: analytics.keyMetrics.totalOrders.toString(),
                change: analytics.keyMetrics.totalOrdersChange,
                isPositive: _isPositiveChange(
                  analytics.keyMetrics.totalOrdersChange,
                ),
              ),
              _buildMetricCard(
                title: 'Avg. Order Value',
                value: _formatCurrency(analytics.keyMetrics.avgOrderValue),
                change: analytics.keyMetrics.avgOrderValueChange,
                isPositive: _isPositiveChange(
                  analytics.keyMetrics.avgOrderValueChange,
                ),
              ),
              _buildMetricCard(
                title: 'Delivery Success',
                value:
                    '${analytics.keyMetrics.deliverySuccess.toStringAsFixed(1)}%',
                change: analytics.keyMetrics.deliverySuccessChange,
                isPositive: _isPositiveChange(
                  analytics.keyMetrics.deliverySuccessChange,
                ),
              ),
              _buildMetricCard(
                title: 'Cancelled Orders',
                value: analytics.keyMetrics.cancelledOrders.toString(),
                change: analytics.keyMetrics.cancelledOrdersChange,
                isPositive: !_isPositiveChange(
                  analytics.keyMetrics.cancelledOrdersChange,
                ),
              ),
            ],
          ),

          const SizedBox(height: ThemeConfig.spaceXL),

          Text('Sales Performance', style: ThemeConfig.heading3),
          const SizedBox(height: ThemeConfig.spaceLG),

          Row(
            children: [
              Expanded(
                child: _buildPerformanceCard(
                  title: 'Conversion Rate',
                  value:
                      '${analytics.salesPerformance.conversionRate.toStringAsFixed(1)}%',
                  description: 'Orders from unique customers',
                ),
              ),
              const SizedBox(width: ThemeConfig.spaceMD),
              Expanded(
                child: _buildPerformanceCard(
                  title: 'Repeat Rate',
                  value:
                      '${analytics.salesPerformance.repeatRate.toStringAsFixed(0)}%',
                  description: 'Percentage of returning customers',
                ),
              ),
            ],
          ),

          const SizedBox(height: ThemeConfig.spaceLG),

          Center(
            child: TextButton.icon(
              onPressed: _loadAnalytics,
              icon: const Icon(Icons.refresh),
              label: Text(
                'Refresh Analytics',
                style: ThemeConfig.bodyMedium.copyWith(
                  color: ThemeConfig.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: ThemeConfig.space2XL),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConfig.spaceLG,
        vertical: ThemeConfig.spaceSM,
      ),
      decoration: BoxDecoration(
        color: ThemeConfig.cardWhite,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
        border: Border.all(color: ThemeConfig.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 16,
            color: ThemeConfig.textSecondary,
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedPeriod,
            underline: const SizedBox(),
            items: _periods.map((period) {
              return DropdownMenuItem(
                value: period,
                child: Text(
                  period,
                  style: ThemeConfig.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
            onChanged: _onPeriodChanged,
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(AnalyticsData analytics) {
    final spots = _revenueSpots(analytics);
    final months = analytics.revenueTrend
        .map((trend) => trend.month)
        .where((month) => month.isNotEmpty)
        .toList();
    final maxY = (_maxRevenue(analytics) * 1.2).ceilToDouble();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: ThemeConfig.borderColor,
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 58,
            getTitlesWidget: (value, meta) {
              return Text(
                _formatCompactCurrency(value),
                style: ThemeConfig.captionText.copyWith(
                  color: ThemeConfig.textLight,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < months.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    months[index],
                    style: ThemeConfig.captionText.copyWith(
                      color: ThemeConfig.textLight,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (spots.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: ThemeConfig.primaryBlue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: ThemeConfig.primaryBlue,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ThemeConfig.primaryBlue.withValues(alpha: 0.3),
                ThemeConfig.primaryBlue.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _revenueSpots(AnalyticsData analytics) {
    final spots = analytics.revenueTrend
        .asMap()
        .entries
        .map(
          (entry) => FlSpot(
            entry.key.toDouble(),
            entry.value.revenue,
          ),
        )
        .toList();

    if (spots.isEmpty) return const [FlSpot(0, 0)];
    if (spots.length == 1) {
      return [spots.first, FlSpot(1, spots.first.y)];
    }
    return spots;
  }

  double _maxRevenue(AnalyticsData analytics) {
    if (analytics.revenueTrend.isEmpty) return 1000;
    final maxRevenue = analytics.revenueTrend
        .map((trend) => trend.revenue)
        .reduce((a, b) => a > b ? a : b);

    return maxRevenue.clamp(1000, double.infinity).toDouble();
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(ThemeConfig.spaceLG),
      decoration: BoxDecoration(
        color: ThemeConfig.backgroundColor,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
        border: Border.all(color: ThemeConfig.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: ThemeConfig.bodySmall.copyWith(
              color: ThemeConfig.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: ThemeConfig.heading1.copyWith(fontSize: 28)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: isPositive
                    ? ThemeConfig.inStock
                    : ThemeConfig.outOfStock,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  change,
                  style: ThemeConfig.captionText.copyWith(
                    color: isPositive
                        ? ThemeConfig.inStock
                        : ThemeConfig.outOfStock,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard({
    required String title,
    required String value,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(ThemeConfig.spaceLG),
      decoration: BoxDecoration(
        color: ThemeConfig.cardWhite,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
        border: Border.all(color: ThemeConfig.borderColor),
        boxShadow: ThemeConfig.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ThemeConfig.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(value, style: ThemeConfig.heading1.copyWith(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            description,
            style: ThemeConfig.captionText.copyWith(
              color: ThemeConfig.textLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  bool _isPositiveChange(String change) {
    return change.startsWith('+');
  }

  String _formatCurrency(double value) {
    return '${AppConfig.currency}${value.toStringAsFixed(0)}';
  }

  String _formatCompactCurrency(double value) {
    if (value >= 1000000) {
      return '${AppConfig.currency}${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${AppConfig.currency}${(value / 1000).toStringAsFixed(1)}K';
    }
    return '${AppConfig.currency}${value.toStringAsFixed(0)}';
  }
}
