class SalesAnalytics {
  final double totalSales;
  final int totalOrders;
  final int ongoingOrders;
  final double averageOrderValue;
  final Map<String, double> categoryRevenue;
  final List<String> topSellingItems;
  final Map<int, int> hourlyOrderCount;

  const SalesAnalytics({
    this.totalSales = 0.0,
    this.totalOrders = 0,
    this.ongoingOrders = 0,
    this.averageOrderValue = 0.0,
    this.categoryRevenue = const {},
    this.topSellingItems = const [],
    this.hourlyOrderCount = const {},
  });

  Map<String, dynamic> toJson() => {
    'totalSales': totalSales,
    'totalOrders': totalOrders,
    'ongoingOrders': ongoingOrders,
    'averageOrderValue': averageOrderValue,
    'categoryRevenue': categoryRevenue,
    'topSellingItems': topSellingItems,
    'hourlyOrderCount': hourlyOrderCount,
  };

  SalesAnalytics copyWith({
    double? totalSales,
    int? totalOrders,
    int? ongoingOrders,
    double? averageOrderValue,
    Map<String, double>? categoryRevenue,
    List<String>? topSellingItems,
    Map<int, int>? hourlyOrderCount,
  }) {
    return SalesAnalytics(
      totalSales: totalSales ?? this.totalSales,
      totalOrders: totalOrders ?? this.totalOrders,
      ongoingOrders: ongoingOrders ?? this.ongoingOrders,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      categoryRevenue: categoryRevenue ?? this.categoryRevenue,
      topSellingItems: topSellingItems ?? this.topSellingItems,
      hourlyOrderCount: hourlyOrderCount ?? this.hourlyOrderCount,
    );
  }
}