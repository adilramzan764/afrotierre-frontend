// lib/Models/SellerModels/SellerDashboardModels.dart

import 'package:afrotierre/Models/SellerModels/SellerAuthModels.dart';
import 'package:flutter/material.dart';

import '../BuyerModels/BuyerOrderModels.dart';

// ============================================
// ENUMS
// ============================================

enum OrderStatus {
  pending,
  paid,
  processing,
  ready,
  shipped,
  delivered,
  cancelled,
  refunded;

  String get displayValue {
    switch (this) {
      case OrderStatus.pending:
        return 'New';
      case OrderStatus.paid:
        return 'New';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.ready:
        return 'Ready to Ship';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  String get statusColor {
    switch (this) {
      case OrderStatus.pending:
      case OrderStatus.paid:
        return '#FFA000';
      case OrderStatus.processing:
        return '#FF6B00';
      case OrderStatus.ready:
        return '#4CAF50';
      case OrderStatus.shipped:
        return '#2196F3';
      case OrderStatus.delivered:
        return '#00BCD4';
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return '#F44336';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
      case OrderStatus.paid:
        return Colors.orange;
      case OrderStatus.processing:
        return const Color(0xFFFF6B00);
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.teal;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return Colors.red;
    }
  }
}

enum WithdrawalStatus {
  pending,
  processing,
  completed,
  rejected;

  String get displayValue {
    switch (this) {
      case WithdrawalStatus.pending:
        return 'Pending';
      case WithdrawalStatus.processing:
        return 'Processing';
      case WithdrawalStatus.completed:
        return 'Completed';
      case WithdrawalStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case WithdrawalStatus.pending:
        return Colors.orange;
      case WithdrawalStatus.processing:
        return Colors.blue;
      case WithdrawalStatus.completed:
        return Colors.green;
      case WithdrawalStatus.rejected:
        return Colors.red;
    }
  }
}

enum TransactionType {
  sale,
  withdrawal,
  fee,
  refund,
  salePending,
  saleAvailable;

  String get displayValue {
    switch (this) {
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.fee:
        return 'Commission';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.salePending:
        return 'Pending Earnings';
      case TransactionType.saleAvailable:
        return 'Released Earnings';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.sale:
      case TransactionType.saleAvailable:
        return Icons.arrow_upward;
      case TransactionType.withdrawal:
        return Icons.arrow_downward;
      case TransactionType.fee:
        return Icons.local_atm;
      case TransactionType.refund:
        return Icons.replay;
      case TransactionType.salePending:
        return Icons.hourglass_empty;
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.sale:
      case TransactionType.saleAvailable:
        return Colors.green;
      case TransactionType.withdrawal:
        return Colors.red;
      case TransactionType.fee:
        return Colors.orange;
      case TransactionType.refund:
        return Colors.purple;
      case TransactionType.salePending:
        return Colors.blue;
    }
  }
}

enum PaymentMethod {
  bankTransfer,
  paypal,
  stripe;

  String get displayValue {
    switch (this) {
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.stripe:
        return 'Stripe';
    }
  }
}

// ============================================
// DASHBOARD OVERVIEW MODEL (NEW)
// ============================================

class DashboardOverview {
  final double totalSales;
  final double availableBalance;
  final double pendingBalance;
  final int newOrders;
  final int pendingOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final int totalOrders;

  DashboardOverview({
    required this.totalSales,
    required this.availableBalance,
    required this.pendingBalance,
    required this.newOrders,
    required this.pendingOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.totalOrders,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      availableBalance: (json['availableBalance'] ?? 0).toDouble(),
      pendingBalance: (json['pendingBalance'] ?? 0).toDouble(),
      newOrders: json['newOrders'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      shippedOrders: json['shippedOrders'] ?? 0,
      deliveredOrders: json['deliveredOrders'] ?? 0,
      cancelledOrders: json['cancelledOrders'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
    );
  }
}

// ============================================
// THIS WEEK STATS MODEL (NEW)
// ============================================

class ThisWeekStats {
  final int orders;
  final double revenue;

  ThisWeekStats({
    required this.orders,
    required this.revenue,
  });

  factory ThisWeekStats.fromJson(Map<String, dynamic> json) {
    return ThisWeekStats(
      orders: json['orders'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

// ============================================
// SALES STATISTICS MODELS (UPDATED)
// ============================================

class SalesStatisticsResponse {
  final String timeframe;
  final DateRange dateRange;
  final SalesStatsData stats;
  final NetEarningsData netEarnings;
  final List<MonthlySalesData> chartData;
  final List<TopProduct> topProducts;
  final DownloadOptions downloadOptions;

  SalesStatisticsResponse({
    required this.timeframe,
    required this.dateRange,
    required this.stats,
    required this.netEarnings,
    required this.chartData,
    required this.topProducts,
    required this.downloadOptions,
  });

  factory SalesStatisticsResponse.fromJson(Map<String, dynamic> json) {
    return SalesStatisticsResponse(
      timeframe: json['timeframe'] ?? '30days',
      dateRange: DateRange.fromJson(json['dateRange'] ?? {}),
      stats: SalesStatsData.fromJson(json['stats'] ?? {}),
      netEarnings: NetEarningsData.fromJson(json['netEarnings'] ?? {}),
      chartData: (json['chartData'] as List?)
          ?.map((e) => MonthlySalesData.fromJson(e))
          .toList() ?? [],
      topProducts: (json['topProducts'] as List?)
          ?.map((e) => TopProduct.fromJson(e))
          .toList() ?? [],
      downloadOptions: DownloadOptions.fromJson(json['downloadOptions'] ?? {}),
    );
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({
    required this.start,
    required this.end,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: json['start'] != null ? DateTime.parse(json['start']) : DateTime.now(),
      end: json['end'] != null ? DateTime.parse(json['end']) : DateTime.now(),
    );
  }

  String get formattedRange {
    return '${start.month}/${start.day}/${start.year} - ${end.month}/${end.day}/${end.year}';
  }
}

class SalesStatsData {
  final MetricData totalRevenue;
  final MetricData ordersCompleted;
  final MetricData avgOrderValue;
  final MetricData refunds;

  SalesStatsData({
    required this.totalRevenue,
    required this.ordersCompleted,
    required this.avgOrderValue,
    required this.refunds,
  });

  factory SalesStatsData.fromJson(Map<String, dynamic> json) {
    return SalesStatsData(
      totalRevenue: MetricData.fromJson(json['totalRevenue'] ?? {}),
      ordersCompleted: MetricData.fromJson(json['ordersCompleted'] ?? {}),
      avgOrderValue: MetricData.fromJson(json['avgOrderValue'] ?? {}),
      refunds: MetricData.fromJson(json['refunds'] ?? {}),
    );
  }
}

class MetricData {
  final double value;
  final String formatted;
  final double change;
  final String changeType;
  final String changeText;

  MetricData({
    required this.value,
    required this.formatted,
    required this.change,
    required this.changeType,
    required this.changeText,
  });

  factory MetricData.fromJson(Map<String, dynamic> json) {
    return MetricData(
      value: (json['value'] ?? 0).toDouble(),
      formatted: json['formatted'] ?? '\$0.00',
      change: (json['change'] ?? 0).toDouble(),
      changeType: json['changeType'] ?? 'positive',
      changeText: json['changeText'] ?? '0% from last period',
    );
  }

  bool get isPositive => changeType == 'positive';
  Color get changeColor => isPositive ? Colors.green : Colors.red;
  IconData get changeIcon => isPositive ? Icons.arrow_upward : Icons.arrow_downward;
}

class NetEarningsData {
  final double value;
  final String formatted;
  final bool afterRefundsAndFees;

  NetEarningsData({
    required this.value,
    required this.formatted,
    required this.afterRefundsAndFees,
  });

  factory NetEarningsData.fromJson(Map<String, dynamic> json) {
    return NetEarningsData(
      value: (json['value'] ?? 0).toDouble(),
      formatted: json['formatted'] ?? '\$0.00',
      afterRefundsAndFees: json['afterRefundsAndFees'] ?? true,
    );
  }
}

class MonthlySalesData {
  final String month;
  final int monthIndex;
  final int year;
  final double income;
  final double refunds;
  final String incomeFormatted;
  final String refundsFormatted;

  MonthlySalesData({
    required this.month,
    required this.monthIndex,
    required this.year,
    required this.income,
    required this.refunds,
    required this.incomeFormatted,
    required this.refundsFormatted,
  });

  factory MonthlySalesData.fromJson(Map<String, dynamic> json) {
    return MonthlySalesData(
      month: json['month'] ?? '',
      monthIndex: json['monthIndex'] ?? 0,
      year: json['year'] ?? 2024,
      income: (json['income'] ?? 0).toDouble(),
      refunds: (json['refunds'] ?? 0).toDouble(),
      incomeFormatted: json['incomeFormatted'] ?? '\$0.00',
      refundsFormatted: json['refundsFormatted'] ?? '\$0.00',
    );
  }
}

class TopProduct {
  final String productId;
  final String name;
  final int quantity;
  final double revenue;
  final String revenueFormatted;

  TopProduct({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.revenue,
    required this.revenueFormatted,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      revenueFormatted: json['revenueFormatted'] ?? '\$0.00',
    );
  }
}

class DownloadOptions {
  final List<String> formats;
  final bool available;

  DownloadOptions({
    required this.formats,
    required this.available,
  });

  factory DownloadOptions.fromJson(Map<String, dynamic> json) {
    return DownloadOptions(
      formats: (json['formats'] as List?)?.map((e) => e.toString()).toList() ?? [],
      available: json['available'] ?? false,
    );
  }
}

// ============================================
// EXISTING MODELS (UPDATED)
// ============================================

class SellerInfo {
  final String id;
  final String storeName;
  final String email;
  final String? phoneNumber;
  final Logo? logo;
  final String status;

  SellerInfo({
    required this.id,
    required this.storeName,
    required this.email,
    this.phoneNumber,
    this.logo,
    this.status = 'active',
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    Logo? logoValue;

    if (json['logo'] != null) {
      if (json['logo'] is Map && json['logo'].isEmpty) {
        logoValue = null;
      } else if (json['logo'] is String) {
        logoValue = Logo(url: json['logo']);
      } else if (json['logo'] is Map) {
        logoValue = Logo.fromJson(json['logo']);
      }
    }

    return SellerInfo(
      id: json['id'] ?? json['_id'] ?? '',
      storeName: json['storeName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      logo: logoValue,
      status: json['status'] ?? 'active',
    );
  }

  String? get logoUrl => logo?.url;
  bool get hasLogo => logo != null;
}

// UPDATED DashboardData with new structure
class DashboardData {
  final SellerInfo seller;
  final DashboardOverview overview;
  final ThisWeekStats thisWeek;
  final OrdersStats orders;
  final SalesStats sales;
  final List<RecentOrder> recentOrders;
  final ProductStats products;
  final List<WeeklyPerformanceItem> weeklyPerformance;
  final WithdrawalInfo withdrawal;
  final String timeframe;

  DashboardData({
    required this.seller,
    required this.overview,
    required this.thisWeek,
    required this.orders,
    required this.sales,
    required this.recentOrders,
    required this.products,
    required this.weeklyPerformance,
    required this.withdrawal,
    required this.timeframe,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      seller: SellerInfo.fromJson(json['seller'] ?? {}),
      overview: DashboardOverview.fromJson(json['overview'] ?? {}),
      thisWeek: ThisWeekStats.fromJson(json['thisWeek'] ?? {}),
      orders: OrdersStats.fromJson(json['orders'] ?? {}),
      sales: SalesStats.fromJson(json['sales'] ?? {}),
      recentOrders: (json['recentOrders'] as List?)
          ?.map((e) => RecentOrder.fromJson(e))
          .toList() ?? [],
      products: ProductStats.fromJson(json['products'] ?? {}),
      weeklyPerformance: (json['weeklyPerformance'] as List?)
          ?.map((e) => WeeklyPerformanceItem.fromJson(e))
          .toList() ?? [],
      withdrawal: WithdrawalInfo.fromJson(json['withdrawal'] ?? {}),
      timeframe: json['timeframe'] ?? 'week',
    );
  }
}

class OrdersStats {
  final Map<String, int> byStatus;
  final int thisWeek;
  final int thisMonth;

  OrdersStats({
    required this.byStatus,
    required this.thisWeek,
    required this.thisMonth,
  });

  factory OrdersStats.fromJson(Map<String, dynamic> json) {
    return OrdersStats(
      byStatus: Map<String, int>.from(json['byStatus'] ?? {}),
      thisWeek: json['thisWeek'] ?? 0,
      thisMonth: json['thisMonth'] ?? 0,
    );
  }

  int get newOrders => byStatus['new'] ?? 0;
  int get pendingOrders => byStatus['pending'] ?? 0;
  int get processing => byStatus['processing'] ?? 0;
  int get shipped => byStatus['shipped'] ?? 0;
  int get delivered => byStatus['delivered'] ?? 0;
  int get cancelled => byStatus['cancelled'] ?? 0;
  int get total => byStatus['total'] ?? 0;
}

class SalesStats {
  final double totalSales;
  final int orderCount;
  final double avgOrderValue;
  final double growth;

  SalesStats({
    required this.totalSales,
    required this.orderCount,
    required this.avgOrderValue,
    required this.growth,
  });

  factory SalesStats.fromJson(Map<String, dynamic> json) {
    return SalesStats(
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      orderCount: json['orderCount'] ?? 0,
      avgOrderValue: (json['avgOrderValue'] ?? 0).toDouble(),
      growth: (json['growth'] ?? 0).toDouble(),
    );
  }
}

class ProductStats {
  final int total;
  final int active;
  final int lowStock;
  final int outOfStock;

  ProductStats({
    required this.total,
    required this.active,
    required this.lowStock,
    required this.outOfStock,
  });

  factory ProductStats.fromJson(Map<String, dynamic> json) {
    return ProductStats(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      lowStock: json['lowStock'] ?? 0,
      outOfStock: json['outOfStock'] ?? 0,
    );
  }
}

class WeeklyPerformanceItem {
  final String day;
  final String date;
  final int orders;
  final double revenue;

  WeeklyPerformanceItem({
    required this.day,
    required this.date,
    required this.orders,
    required this.revenue,
  });

  factory WeeklyPerformanceItem.fromJson(Map<String, dynamic> json) {
    return WeeklyPerformanceItem(
      day: json['day'] ?? '',
      date: json['date'] ?? '',
      orders: json['orders'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

class WithdrawalInfo {
  final double availableBalance;
  final double pendingBalance;
  final double pendingWithdrawalRequest;
  final double totalWithdrawn;

  WithdrawalInfo({
    required this.availableBalance,
    required this.pendingBalance,
    required this.pendingWithdrawalRequest,
    required this.totalWithdrawn,
  });

  factory WithdrawalInfo.fromJson(Map<String, dynamic> json) {
    return WithdrawalInfo(
      availableBalance: (json['availableBalance'] ?? 0).toDouble(),
      pendingBalance: (json['pendingBalance'] ?? 0).toDouble(),
      pendingWithdrawalRequest: (json['pendingWithdrawalRequest'] ?? 0).toDouble(),
      totalWithdrawn: (json['totalWithdrawn'] ?? 0).toDouble(),
    );
  }
}

// Keep existing models (RecentOrder, OrderDetailsForSeller, etc.)
// They remain the same as before...

class RecentOrder {
  final String id;
  final String orderNumber;
  final String? mainOrderNumber;
  final int productCount;
  final double totalAmount;
  final OrderStatus status;
  final String statusDisplay;
  final String statusColor;
  final DateTime createdAt;
  final String? buyerName;
  final String? trackingNumber;
  final List<RecentOrderProduct> products;

  RecentOrder({
    required this.id,
    required this.orderNumber,
    this.mainOrderNumber,
    required this.productCount,
    required this.totalAmount,
    required this.status,
    required this.statusDisplay,
    required this.statusColor,
    required this.createdAt,
    this.buyerName,
    this.trackingNumber,
    required this.products,
  });

  factory RecentOrder.fromJson(Map<String, dynamic> json) {
    OrderStatus orderStatus = getOrderStatusFromString(json['status']);

    return RecentOrder(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      mainOrderNumber: json['mainOrderNumber'],
      productCount: json['productCount'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: orderStatus,
      statusDisplay: json['statusDisplay'] ?? orderStatus.displayValue,
      statusColor: json['statusColor'] ?? orderStatus.statusColor,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      buyerName: json['buyerName'] ?? 'Guest',
      trackingNumber: json['trackingNumber'],
      products: (json['products'] as List?)
          ?.map((e) => RecentOrderProduct.fromJson(e))
          .toList() ?? [],
    );
  }

  String get formattedDate {
    return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
  }
}

class RecentOrderProduct {
  final String? id;
  final String name;
  final int quantity;
  final double price;
  final String? image;

  RecentOrderProduct({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.image,
  });

  factory RecentOrderProduct.fromJson(Map<String, dynamic> json) {
    return RecentOrderProduct(
      id: json['id'],
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'],
    );
  }
}

// Helper function
OrderStatus getOrderStatusFromString(String? status) {
  switch (status) {
    case 'shipped':
      return OrderStatus.shipped;
    case 'delivered':
      return OrderStatus.delivered;
    case 'cancelled':
      return OrderStatus.cancelled;
    case 'refunded':
      return OrderStatus.refunded;
    case 'paid':
      return OrderStatus.paid;
    case 'processing':
      return OrderStatus.processing;
    case 'ready':
      return OrderStatus.ready;
    default:
      return OrderStatus.pending;
  }
}