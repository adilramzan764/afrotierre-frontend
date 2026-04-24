// lib/Repository/SellerRepository/SellerPayoutRepository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Constants/ApiConstants.dart';
import '../../Models/SellerModels/SellerPayoutModels.dart';
import '../../Services/AppSession.dart';

class SellerPayoutRepository {
  static const String baseUrl = ApiConstants.baseUrlSeller;

  final AppSession _sessionService = AppSession.instance;

  // Helper method to get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    await AppSession.ensureInitialized();
    final token = _sessionService.authToken;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Helper method to handle API responses
  dynamic _handleResponse(http.Response response) {
    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

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

  // ============================================
  // GET PAYOUT STATUS
  // GET /api/seller/payouts/status
  // ============================================
  Future<PayoutStatusResponse> getPayoutStatus() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/payouts/status');

      final response = await http.get(url, headers: headers);

      print("URL: $url");
      final data = _handleResponse(response);
      return PayoutStatusResponse.fromJson(data['data']);
    } catch (e) {
      print('Get payout status error: $e');
      rethrow;
    }
  }

  // ============================================
  // CREATE STRIPE CONNECT ACCOUNT
  // POST /api/seller/payouts/create-stripe-account
  // ============================================
  Future<StripeOnboardingResponse> createStripeConnectAccount() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/payouts/connect');

      final response = await http.post(url, headers: headers);

      print("URL: $url");
      final data = _handleResponse(response);
      return StripeOnboardingResponse.fromJson(data['data']);
    } catch (e) {
      print('Create Stripe account error: $e');
      rethrow;
    }
  }

  // ============================================
  // GET ONBOARDING LINK
  // GET /api/seller/payouts/onboarding-link
  // ============================================
  Future<String> getOnboardingLink() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/payouts/onboarding-link');

      final response = await http.get(url, headers: headers);

      print("URL: $url");
      final data = _handleResponse(response);
      return data['data']['onboardingUrl'];
    } catch (e) {
      print('Get onboarding link error: $e');
      rethrow;
    }
  }

  // ============================================
  // REQUEST WITHDRAWAL
  // POST /api/seller/payouts/withdraw/request
  // ============================================
  Future<WithdrawalResponse> requestWithdrawal({
    required double amount,
    required String paymentMethod,
    required Map<String, dynamic> accountDetails,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/payouts/withdraw');

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
      final data = _handleResponse(response);
      return WithdrawalResponse.fromJson(data['data']);
    } catch (e) {
      print('Request withdrawal error: $e');
      rethrow;
    }
  }

  // ============================================
  // GET WITHDRAWAL HISTORY
  // GET /api/seller/payouts/withdraw/history?page=1&limit=20&status=pending
  // ============================================
  Future<WithdrawalHistoryResponse> getWithdrawalHistory({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/payouts/withdrawals?page=$page&limit=$limit';
      if (status != null) url += '&status=$status';

      final response = await http.get(Uri.parse(url), headers: headers);

      print("URL: $url");
      final data = _handleResponse(response);
      return WithdrawalHistoryResponse.fromJson(data['data']);
    } catch (e) {
      print('Get withdrawal history error: $e');
      rethrow;
    }
  }

  // ============================================
  // GET TRANSACTION HISTORY (Payout specific)
  // GET /api/seller/payouts/transactions?page=1&limit=20
  // ============================================
  Future<PayoutTransactionHistoryResponse> getPayoutTransactionHistory({
    int page = 1,
    int limit = 20,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/payouts/transactions?page=$page&limit=$limit';
      if (type != null) url += '&type=$type';
      if (startDate != null) url += '&startDate=${startDate.toIso8601String()}';
      if (endDate != null) url += '&endDate=${endDate.toIso8601String()}';

      final response = await http.get(Uri.parse(url), headers: headers);

      print("URL: $url");
      final data = _handleResponse(response);
      return PayoutTransactionHistoryResponse.fromJson(data['data']);
    } catch (e) {
      print('Get payout transaction history error: $e');
      rethrow;
    }
  }

  // ============================================
  // TEST FORCE RELEASE (DEBUG ONLY)
  // POST /api/seller/payouts/test-force-release
  // ============================================
  Future<Map<String, dynamic>> testForceRelease() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/payouts/test-force-release');

      final response = await http.post(url, headers: headers);

      print("URL: $url");
      final data = _handleResponse(response);
      return data['data'] ?? {};
    } catch (e) {
      print('Test force release error: $e');
      rethrow;
    }
  }
}

// Additional response model for payout transactions
class PayoutTransactionHistoryResponse {
  final List<PayoutTransaction> transactions;
  final PayoutTransactionSummary summary;
  final PaginationInfo pagination;

  PayoutTransactionHistoryResponse({
    required this.transactions,
    required this.summary,
    required this.pagination,
  });

  factory PayoutTransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return PayoutTransactionHistoryResponse(
      transactions: (json['transactions'] as List?)
          ?.map((e) => PayoutTransaction.fromJson(e))
          .toList() ?? [],
      summary: PayoutTransactionSummary.fromJson(json['summary'] ?? {}),
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class PayoutTransactionSummary {
  final double totalSales;
  final double totalWithdrawn;
  final double totalFees;
  final double availableBalance;

  PayoutTransactionSummary({
    required this.totalSales,
    required this.totalWithdrawn,
    required this.totalFees,
    required this.availableBalance,
  });

  factory PayoutTransactionSummary.fromJson(Map<String, dynamic> json) {
    return PayoutTransactionSummary(
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      totalWithdrawn: (json['totalWithdrawn'] ?? 0).toDouble(),
      totalFees: (json['totalFees'] ?? 0).toDouble(),
      availableBalance: (json['availableBalance'] ?? 0).toDouble(),
    );
  }
}