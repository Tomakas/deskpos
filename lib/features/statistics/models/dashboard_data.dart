import 'dart:ui';

class DashboardData {
  DashboardData({
    required this.totalRevenue,
    required this.billCount,
    required this.averageBill,
    required this.totalTips,
    required this.prevTotalRevenue,
    required this.prevBillCount,
    required this.prevAverageBill,
    required this.prevTotalTips,
    required this.revenueByPeriod,
    required this.paymentMethodBreakdown,
    required this.categoryBreakdown,
    required this.topProducts,
    required this.heatmapData,
  });

  final int totalRevenue; // cents
  final int billCount;
  final int averageBill; // cents
  final int totalTips; // cents
  final int prevTotalRevenue; // previous period
  final int prevBillCount;
  final int prevAverageBill;
  final int prevTotalTips;
  final List<RevenueBarEntry> revenueByPeriod;
  final List<DonutEntry> paymentMethodBreakdown;
  final List<DonutEntry> categoryBreakdown;
  final List<TopProductEntry> topProducts;
  final List<List<double>> heatmapData; // [7 days][24 hours] = avg revenue
}

class RevenueBarEntry {
  RevenueBarEntry({required this.label, required this.value});
  final String label;
  final int value;
}

class DonutEntry {
  DonutEntry({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;
}

class TopProductEntry {
  TopProductEntry({
    required this.name,
    required this.quantity,
    required this.revenue,
  });
  final String name;
  final double quantity;
  final int revenue;
}
