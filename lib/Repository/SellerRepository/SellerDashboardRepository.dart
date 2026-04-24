// lib/Repository/SellerRepository/SellerDashboardRepository.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../Constants/ApiConstants.dart';
import '../../Models/SellerModels/SellerDashboardModels.dart';
import '../../Services/AppSession.dart';

class SellerDashboardRepository {
  static const String baseUrl = ApiConstants.baseUrlSeller;

  final SellerDashboardSessionService _sessionService = SellerDashboardSessionService();

  // Helper method to get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _sessionService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Helper method to handle API responses
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Request failed');
      }
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Server error: ${response.statusCode}');
      } catch (e) {
        throw Exception('Server error: ${response.statusCode}');
      }
    }
  }

  /**
   * Get dashboard data
   * GET /api/seller/dashboard?timeframe=week|month|year
   */
  Future<DashboardData> getDashboardData({String timeframe = 'week'}) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/dashboard?timeframe=$timeframe');

      final response = await http.get(url, headers: headers);

      print("URL: $url");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return DashboardData.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to get dashboard data: $e');
    }
  }

  /**
   * Get sales statistics with chart data
   * GET /api/seller/dashboard/sales-statistics?timeframe=30days
   */
  Future<SalesStatisticsResponse> getSalesStatistics({String timeframe = '30days'}) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/dashboard/statistics?timeframe=$timeframe');

      final response = await http.get(url, headers: headers);

      print("URL: $url");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return SalesStatisticsResponse.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to get sales statistics: $e');
    }
  }

  /**
   * Download sales report
   * GET /api/seller/dashboard/sales/download-report?format=csv&timeframe=30days
   */
  Future<File?> downloadSalesReport({String format = 'csv', String timeframe = '30days'}) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/dashboard/download-report?format=$format&timeframe=$timeframe');

      final response = await http.get(url, headers: headers);

      print("URL: $url");
      print("Response Status: ${response.statusCode}");
      print("Response Body Length: ${response.bodyBytes.length}");

      if (response.statusCode == 200) {
        // Save to app's documents directory (always accessible)
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'sales_report_$timestamp.$format';
        final file = File('${directory.path}/$fileName');

        await file.writeAsBytes(response.bodyBytes);

        print("✅ File saved to: ${file.path}");
        print("📁 File size: ${await file.length()} bytes");

        // Also try to copy to Downloads if possible (optional)
        await _copyToDownloadsIfPossible(file);

        return file;
      } else {
        throw Exception('Failed to download report: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Download error: $e");
      throw Exception('Failed to download sales report: $e');
    }
  }

// Optional: Try to copy to Downloads folder (won't crash if fails)
  Future<void> _copyToDownloadsIfPossible(File sourceFile) async {
    try {
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (await downloadsDir.exists()) {
        final fileName = sourceFile.path.split('/').last;
        final destFile = File('${downloadsDir.path}/$fileName');
        await sourceFile.copy(destFile.path);
        print("📁 Also copied to Downloads: ${destFile.path}");
      }
    } catch (e) {
      print("⚠️ Could not copy to Downloads: $e");
      // Don't throw - this is optional
    }
  }

  /**
   * Get orders overview
   * GET /api/seller/dashboard/orders-overview
   */
  Future<OrdersOverview> getOrdersOverview() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/dashboard/orders-overview');

      final response = await http.get(url, headers: headers);

      print("URL: $url");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return OrdersOverview.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to get orders overview: $e');
    }
  }

  /**
   * Get weekly performance
   * GET /api/seller/dashboard/weekly-performance
   */
  Future<List<WeeklyPerformanceItem>> getWeeklyPerformance() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/dashboard/weekly-performance');

      final response = await http.get(url, headers: headers);

      print("URL: $url");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return (data['data'] as List?)
          ?.map((e) => WeeklyPerformanceItem.fromJson(e))
          .toList() ?? [];
    } catch (e) {
      throw Exception('Failed to get weekly performance: $e');
    }
  }

  /**
   * Get recent orders list
   * GET /api/seller/dashboard/recent-orders?page=1&limit=20
   */
  Future<RecentOrdersListResponse> getRecentOrdersList({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/dashboard/recent-orders?page=$page&limit=$limit');

      final response = await http.get(url, headers: headers);

      print("URL: $url");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return RecentOrdersListResponse.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to get recent orders: $e');
    }
  }



  /**
   * Update order status
   * PUT /api/seller/dashboard/orders/:orderId/status
   */
  Future<Map<String, dynamic>> updateOrderStatus(
      String orderId,
      String status, {
        String? trackingNumber,
        String? carrier,
      }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/dashboard/orders/$orderId/status');

      final body = {
        'status': status,
      };
      if (trackingNumber != null) body['trackingNumber'] = trackingNumber;
      if (carrier != null) body['carrier'] = carrier;

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(body),
      );

      print("URL: $url");
      print("Request Body: ${json.encode(body)}");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return {
        'success': true,
        'message': data['message'],
        'data': data['data'],
      };
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /**
   * Get transaction history
   * GET /api/seller/dashboard/transactions?page=1&limit=20
   */
  Future<TransactionHistoryResponse> getTransactionHistory({
    int page = 1,
    int limit = 20,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/transactions?page=$page&limit=$limit';
      if (type != null) url += '&type=$type';
      if (startDate != null) url += '&startDate=${startDate.toIso8601String()}';
      if (endDate != null) url += '&endDate=${endDate.toIso8601String()}';

      final response = await http.get(Uri.parse(url), headers: headers);

      print("URL: $url");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return TransactionHistoryResponse.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to get transaction history: $e');
    }
  }

  /**
   * Request withdrawal
   * POST /api/seller/dashboard/withdraw/request
   */
  Future<Map<String, dynamic>> requestWithdrawal({
    required double amount,
    required String paymentMethod,
    required Map<String, dynamic> accountDetails,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/withdraw/request');

      final body = {
        'amount': amount,
        'paymentMethod': paymentMethod,
        'accountDetails': accountDetails,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      print("URL: $url");
      print("Request Body: ${json.encode(body)}");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return {
        'success': true,
        'message': data['message'],
        'data': data['data'],
      };
    } catch (e) {
      throw Exception('Failed to request withdrawal: $e');
    }
  }

  /**
   * Get withdrawal history
   * GET /api/seller/dashboard/withdraw/history?page=1&limit=20
   */
  Future<WithdrawalHistoryResponse> getWithdrawalHistory({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/withdraw/history?page=$page&limit=$limit';
      if (status != null) url += '&status=$status';

      final response = await http.get(Uri.parse(url), headers: headers);

      print("URL: $url");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return WithdrawalHistoryResponse.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to get withdrawal history: $e');
    }
  }
}

// Helper service to get auth token for seller
class SellerDashboardSessionService {
  Future<String?> getAuthToken() async {
    await AppSession.ensureInitialized();
    return AppSession.instance.authToken;
  }
}

// Response Models

class RecentOrdersListResponse {
  final List<RecentOrder> orders;
  final PaginationInfo pagination;

  RecentOrdersListResponse({
    required this.orders,
    required this.pagination,
  });

  factory RecentOrdersListResponse.fromJson(Map<String, dynamic> json) {
    return RecentOrdersListResponse(
      orders: (json['orders'] as List?)
          ?.map((e) => RecentOrder.fromJson(e))
          .toList() ?? [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class OrdersOverview {
  final int newOrders;
  final int processing;
  final int ready;
  final int shipped;
  final int delivered;
  final int cancelled;

  OrdersOverview({
    required this.newOrders,
    required this.processing,
    required this.ready,
    required this.shipped,
    required this.delivered,
    required this.cancelled,
  });

  factory OrdersOverview.fromJson(Map<String, dynamic> json) {
    return OrdersOverview(
      newOrders: json['new'] ?? 0,
      processing: json['processing'] ?? 0,
      ready: json['ready'] ?? 0,
      shipped: json['shipped'] ?? 0,
      delivered: json['delivered'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
    );
  }
}

class TransactionHistoryResponse {
  final List<Transaction> transactions;
  final TransactionSummary summary;
  final PaginationInfo pagination;

  TransactionHistoryResponse({
    required this.transactions,
    required this.summary,
    required this.pagination,
  });

  factory TransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryResponse(
      transactions: (json['transactions'] as List?)
          ?.map((e) => Transaction.fromJson(e))
          .toList() ?? [],
      summary: TransactionSummary.fromJson(json['summary'] ?? {}),
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final double netAmount;
  final String status;
  final String description;
  final String? reference;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.netAmount,
    required this.status,
    required this.description,
    this.reference,
    required this.createdAt,
    this.metadata,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    TransactionType type = getTransactionTypeFromString(json['type']);

    return Transaction(
      id: json['_id'] ?? '',
      type: type,
      amount: (json['amount'] ?? 0).toDouble(),
      netAmount: (json['netAmount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      reference: json['reference'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  bool get isPositive => netAmount > 0;
  String get formattedAmount => isPositive ? '+${_formatCurrency(netAmount)}' : _formatCurrency(netAmount);

  String _formatCurrency(double amount) {
    return '\$${amount.abs().toStringAsFixed(2)}';
  }
}

class TransactionSummary {
  final double totalSales;
  final double totalWithdrawn;
  final double totalFees;
  final double availableBalance;

  TransactionSummary({
    required this.totalSales,
    required this.totalWithdrawn,
    required this.totalFees,
    required this.availableBalance,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      totalWithdrawn: (json['totalWithdrawn'] ?? 0).toDouble(),
      totalFees: (json['totalFees'] ?? 0).toDouble(),
      availableBalance: (json['availableBalance'] ?? 0).toDouble(),
    );
  }
}

class WithdrawalHistoryResponse {
  final List<Withdrawal> withdrawals;
  final WithdrawalSummary summary;
  final PaginationInfo pagination;

  WithdrawalHistoryResponse({
    required this.withdrawals,
    required this.summary,
    required this.pagination,
  });

  factory WithdrawalHistoryResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawalHistoryResponse(
      withdrawals: (json['withdrawals'] as List?)
          ?.map((e) => Withdrawal.fromJson(e))
          .toList() ?? [],
      summary: WithdrawalSummary.fromJson(json['summary'] ?? {}),
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class Withdrawal {
  final String id;
  final double amount;
  final String paymentMethod;
  final WithdrawalStatus status;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final Map<String, dynamic>? accountDetails;

  Withdrawal({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.accountDetails,
  });

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    WithdrawalStatus status = getWithdrawalStatusFromString(json['status']);

    return Withdrawal(
      id: json['_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      status: status,
      requestedAt: json['requestedAt'] != null
          ? DateTime.parse(json['requestedAt'])
          : DateTime.now(),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      accountDetails: json['accountDetails'] as Map<String, dynamic>?,
    );
  }

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  String get formattedDate => '${requestedAt.month}/${requestedAt.day}/${requestedAt.year}';
}

class WithdrawalSummary {
  final WithdrawalStatusSummary pending;
  final WithdrawalStatusSummary processing;
  final WithdrawalStatusSummary completed;
  final WithdrawalStatusSummary rejected;
  final double totalWithdrawn;

  WithdrawalSummary({
    required this.pending,
    required this.processing,
    required this.completed,
    required this.rejected,
    required this.totalWithdrawn,
  });

  factory WithdrawalSummary.fromJson(Map<String, dynamic> json) {
    return WithdrawalSummary(
      pending: WithdrawalStatusSummary.fromJson(json['pending'] ?? {}),
      processing: WithdrawalStatusSummary.fromJson(json['processing'] ?? {}),
      completed: WithdrawalStatusSummary.fromJson(json['completed'] ?? {}),
      rejected: WithdrawalStatusSummary.fromJson(json['rejected'] ?? {}),
      totalWithdrawn: (json['totalWithdrawn'] ?? 0).toDouble(),
    );
  }
}

class WithdrawalStatusSummary {
  final double total;
  final int count;

  WithdrawalStatusSummary({
    required this.total,
    required this.count,
  });

  factory WithdrawalStatusSummary.fromJson(Map<String, dynamic> json) {
    return WithdrawalStatusSummary(
      total: (json['total'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }

  String get formattedTotal => '\$${total.toStringAsFixed(2)}';
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
    );
  }

  bool get hasNextPage => page < pages;
  bool get hasPreviousPage => page > 1;
}

// Helper functions
TransactionType getTransactionTypeFromString(String? type) {
  switch (type) {
    case 'sale':
      return TransactionType.sale;
    case 'withdrawal':
      return TransactionType.withdrawal;
    case 'fee':
    case 'commission':
      return TransactionType.fee;
    case 'refund':
      return TransactionType.refund;
    case 'sale_pending':
      return TransactionType.salePending;
    case 'sale_available':
      return TransactionType.saleAvailable;
    default:
      return TransactionType.sale;
  }
}

WithdrawalStatus getWithdrawalStatusFromString(String? status) {
  switch (status) {
    case 'pending':
      return WithdrawalStatus.pending;
    case 'processing':
      return WithdrawalStatus.processing;
    case 'completed':
      return WithdrawalStatus.completed;
    case 'rejected':
      return WithdrawalStatus.rejected;
    default:
      return WithdrawalStatus.pending;
  }
}