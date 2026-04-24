// lib/Models/SellerModels/SellerPayoutModels.dart

import 'package:flutter/material.dart';

// ============================================
// ENUMS
// ============================================

enum StripeAccountStatus {
  notConnected,
  pending,
  active,
  restricted,
  error;

  String get displayValue {
    switch (this) {
      case StripeAccountStatus.notConnected:
        return 'Not Connected';
      case StripeAccountStatus.pending:
        return 'Pending Setup';
      case StripeAccountStatus.active:
        return 'Active';
      case StripeAccountStatus.restricted:
        return 'Restricted';
      case StripeAccountStatus.error:
        return 'Error';
    }
  }

  Color get color {
    switch (this) {
      case StripeAccountStatus.notConnected:
        return Colors.grey;
      case StripeAccountStatus.pending:
        return Colors.orange;
      case StripeAccountStatus.active:
        return Colors.green;
      case StripeAccountStatus.restricted:
        return Colors.red;
      case StripeAccountStatus.error:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case StripeAccountStatus.notConnected:
        return Icons.link_off;
      case StripeAccountStatus.pending:
        return Icons.hourglass_empty;
      case StripeAccountStatus.active:
        return Icons.check_circle;
      case StripeAccountStatus.restricted:
        return Icons.warning;
      case StripeAccountStatus.error:
        return Icons.error;
    }
  }
}

enum WithdrawalStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled;

  String get displayValue {
    switch (this) {
      case WithdrawalStatus.pending:
        return 'Pending';
      case WithdrawalStatus.processing:
        return 'Processing';
      case WithdrawalStatus.completed:
        return 'Completed';
      case WithdrawalStatus.failed:
        return 'Failed';
      case WithdrawalStatus.cancelled:
        return 'Cancelled';
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
      case WithdrawalStatus.failed:
        return Colors.red;
      case WithdrawalStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case WithdrawalStatus.pending:
        return Icons.hourglass_empty;
      case WithdrawalStatus.processing:
        return Icons.sync;
      case WithdrawalStatus.completed:
        return Icons.check_circle;
      case WithdrawalStatus.failed:
        return Icons.error;
      case WithdrawalStatus.cancelled:
        return Icons.cancel;
    }
  }
}

enum PayoutTransactionType {
  sale,
  withdrawal,
  commission,
  refundDebit,
  salePending,
  saleAvailable;

  String get displayValue {
    switch (this) {
      case PayoutTransactionType.sale:
        return 'Sale';
      case PayoutTransactionType.withdrawal:
        return 'Withdrawal';
      case PayoutTransactionType.commission:
        return 'Commission';
      case PayoutTransactionType.refundDebit:
        return 'Refund';
      case PayoutTransactionType.salePending:
        return 'Pending Earnings';
      case PayoutTransactionType.saleAvailable:
        return 'Released Earnings';
    }
  }

  Color get color {
    switch (this) {
      case PayoutTransactionType.sale:
      case PayoutTransactionType.saleAvailable:
        return Colors.green;
      case PayoutTransactionType.withdrawal:
        return Colors.red;
      case PayoutTransactionType.commission:
        return Colors.orange;
      case PayoutTransactionType.refundDebit:
        return Colors.purple;
      case PayoutTransactionType.salePending:
        return Colors.blue;
    }
  }

  IconData get icon {
    switch (this) {
      case PayoutTransactionType.sale:
      case PayoutTransactionType.saleAvailable:
        return Icons.arrow_upward;
      case PayoutTransactionType.withdrawal:
        return Icons.arrow_downward;
      case PayoutTransactionType.commission:
        return Icons.local_atm;
      case PayoutTransactionType.refundDebit:
        return Icons.replay;
      case PayoutTransactionType.salePending:
        return Icons.hourglass_empty;
    }
  }
}

// ============================================
// MODELS
// ============================================

class SellerWallet {
  final double availableBalance;
  final double pendingBalance;
  final double withdrawnBalance;
  final double negativeBalance;
  final double reserveBalance;
  final double effectiveAvailableBalance;
  final String currency;
  final DateTime lastUpdated;

  SellerWallet({
    required this.availableBalance,
    required this.pendingBalance,
    required this.withdrawnBalance,
    required this.negativeBalance,
    required this.reserveBalance,
    required this.effectiveAvailableBalance,
    required this.currency,
    required this.lastUpdated,
  });

  factory SellerWallet.fromJson(Map<String, dynamic> json) {
    return SellerWallet(
      availableBalance: (json['availableBalance'] ?? 0).toDouble(),
      pendingBalance: (json['pendingBalance'] ?? 0).toDouble(),
      withdrawnBalance: (json['withdrawnBalance'] ?? 0).toDouble(),
      negativeBalance: (json['negativeBalance'] ?? 0).toDouble(),
      reserveBalance: (json['reserveBalance'] ?? 0).toDouble(),
      effectiveAvailableBalance: (json['effectiveAvailableBalance'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  bool get hasNegativeBalance => negativeBalance < 0;
  String get formattedAvailableBalance => '\$${availableBalance.toStringAsFixed(2)}';
  String get formattedPendingBalance => '\$${pendingBalance.toStringAsFixed(2)}';
  String get formattedEffectiveBalance => '\$${effectiveAvailableBalance.toStringAsFixed(2)}';
}

class PayoutStatusResponse {
  final bool stripeConnected;
  final StripeAccountStatus stripeAccountStatus;
  final SellerWallet wallet;
  final List<Withdrawal> recentWithdrawals;
  final List<PayoutTransaction> recentTransactions;
  final DateTime? nextEligiblePayoutDate;
  final double minimumWithdrawal;
  final double automaticPayoutThreshold;

  PayoutStatusResponse({
    required this.stripeConnected,
    required this.stripeAccountStatus,
    required this.wallet,
    required this.recentWithdrawals,
    required this.recentTransactions,
    this.nextEligiblePayoutDate,
    required this.minimumWithdrawal,
    required this.automaticPayoutThreshold,
  });

  factory PayoutStatusResponse.fromJson(Map<String, dynamic> json) {
    StripeAccountStatus accountStatus;
    final status = json['stripeAccountStatus'] ?? 'not_connected';
    switch (status) {
      case 'active':
        accountStatus = StripeAccountStatus.active;
        break;
      case 'pending':
        accountStatus = StripeAccountStatus.pending;
        break;
      case 'restricted':
        accountStatus = StripeAccountStatus.restricted;
        break;
      case 'error':
        accountStatus = StripeAccountStatus.error;
        break;
      default:
        accountStatus = StripeAccountStatus.notConnected;
    }

    return PayoutStatusResponse(
      stripeConnected: json['stripeConnected'] ?? false,
      stripeAccountStatus: accountStatus,
      wallet: SellerWallet.fromJson(json['wallet'] ?? {}),
      recentWithdrawals: (json['recentWithdrawals'] as List?)
          ?.map((e) => Withdrawal.fromJson(e))
          .toList() ?? [],
      recentTransactions: (json['recentTransactions'] as List?)
          ?.map((e) => PayoutTransaction.fromJson(e))
          .toList() ?? [],
      nextEligiblePayoutDate: json['nextEligiblePayoutDate'] != null
          ? DateTime.parse(json['nextEligiblePayoutDate'])
          : null,
      minimumWithdrawal: (json['minimumWithdrawal'] ?? 10).toDouble(),
      automaticPayoutThreshold: (json['automaticPayoutThreshold'] ?? 100).toDouble(),
    );
  }

  bool get canWithdraw => wallet.effectiveAvailableBalance >= minimumWithdrawal;
  bool get needsStripeSetup => !stripeConnected || stripeAccountStatus == StripeAccountStatus.notConnected;
}

class Withdrawal {
  final String id;
  final double amount;
  final String paymentMethod;
  final WithdrawalStatus status;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? notes;
  final Map<String, dynamic>? accountDetails;

  Withdrawal({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.notes,
    this.accountDetails,
  });

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    WithdrawalStatus status;
    final statusStr = json['status'] ?? 'pending';
    switch (statusStr) {
      case 'processing':
        status = WithdrawalStatus.processing;
        break;
      case 'completed':
        status = WithdrawalStatus.completed;
        break;
      case 'failed':
        status = WithdrawalStatus.failed;
        break;
      case 'cancelled':
        status = WithdrawalStatus.cancelled;
        break;
      default:
        status = WithdrawalStatus.pending;
    }

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
      notes: json['notes'],
      accountDetails: json['accountDetails'] as Map<String, dynamic>?,
    );
  }

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  String get formattedDate => '${requestedAt.month}/${requestedAt.day}/${requestedAt.year}';
  String get paymentMethodDisplay {
    switch (paymentMethod) {
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'paypal':
        return 'PayPal';
      case 'stripe':
        return 'Stripe';
      default:
        return paymentMethod;
    }
  }
}

class PayoutTransaction {
  final String id;
  final PayoutTransactionType type;
  final double amount;
  final double netAmount;
  final String status;
  final String description;
  final String? reference;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  PayoutTransaction({
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

  factory PayoutTransaction.fromJson(Map<String, dynamic> json) {
    PayoutTransactionType type;
    final typeStr = json['type'] ?? '';
    switch (typeStr) {
      case 'sale':
        type = PayoutTransactionType.sale;
        break;
      case 'withdrawal':
        type = PayoutTransactionType.withdrawal;
        break;
      case 'commission':
        type = PayoutTransactionType.commission;
        break;
      case 'refund_debit':
        type = PayoutTransactionType.refundDebit;
        break;
      case 'sale_pending':
        type = PayoutTransactionType.salePending;
        break;
      case 'sale_available':
        type = PayoutTransactionType.saleAvailable;
        break;
      default:
        type = PayoutTransactionType.sale;
    }

    return PayoutTransaction(
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

class StripeOnboardingResponse {
  final String onboardingUrl;
  final String accountId;
  final bool isExisting;

  StripeOnboardingResponse({
    required this.onboardingUrl,
    required this.accountId,
    required this.isExisting,
  });

  factory StripeOnboardingResponse.fromJson(Map<String, dynamic> json) {
    return StripeOnboardingResponse(
      onboardingUrl: json['onboardingUrl'] ?? '',
      accountId: json['accountId'] ?? '',
      isExisting: json['isExisting'] ?? false,
    );
  }
}

class WithdrawalRequest {
  final double amount;
  final String paymentMethod;
  final Map<String, dynamic> accountDetails;

  WithdrawalRequest({
    required this.amount,
    required this.paymentMethod,
    required this.accountDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'paymentMethod': paymentMethod,
      'accountDetails': accountDetails,
    };
  }
}

class WithdrawalResponse {
  final String withdrawalId;
  final double amount;
  final String status;
  final DateTime processedAt;
  final String transferId;
  final double newBalance;

  WithdrawalResponse({
    required this.withdrawalId,
    required this.amount,
    required this.status,
    required this.processedAt,
    required this.transferId,
    required this.newBalance,
  });

  factory WithdrawalResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawalResponse(
      withdrawalId: json['withdrawalId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : DateTime.now(),
      transferId: json['transferId'] ?? '',
      newBalance: (json['newBalance'] ?? 0).toDouble(),
    );
  }

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  String get formattedNewBalance => '\$${newBalance.toStringAsFixed(2)}';
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

class WithdrawalSummary {
  final WithdrawalStatusSummary pending;
  final WithdrawalStatusSummary processing;
  final WithdrawalStatusSummary completed;
  final WithdrawalStatusSummary failed;
  final WithdrawalStatusSummary cancelled;
  final double totalWithdrawn;

  WithdrawalSummary({
    required this.pending,
    required this.processing,
    required this.completed,
    required this.failed,
    required this.cancelled,
    required this.totalWithdrawn,
  });

  factory WithdrawalSummary.fromJson(Map<String, dynamic> json) {
    return WithdrawalSummary(
      pending: WithdrawalStatusSummary.fromJson(json['pending'] ?? {}),
      processing: WithdrawalStatusSummary.fromJson(json['processing'] ?? {}),
      completed: WithdrawalStatusSummary.fromJson(json['completed'] ?? {}),
      failed: WithdrawalStatusSummary.fromJson(json['failed'] ?? {}),
      cancelled: WithdrawalStatusSummary.fromJson(json['cancelled'] ?? {}),
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