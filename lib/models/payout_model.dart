import '../core/money/money.dart';

enum LedgerEntryType {
  creditOrderPayment,
  debitCommission,
  debitPayout,
  adjustment;

  static LedgerEntryType fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'CREDIT_ORDER_PAYMENT':
        return LedgerEntryType.creditOrderPayment;
      case 'DEBIT_COMMISSION':
        return LedgerEntryType.debitCommission;
      case 'DEBIT_PAYOUT':
        return LedgerEntryType.debitPayout;
      case 'ADJUSTMENT':
      default:
        return LedgerEntryType.adjustment;
    }
  }

  bool get isCredit => this == LedgerEntryType.creditOrderPayment;
}

class PayoutLedgerEntryModel {
  final String id;
  final int amountPaisa;
  final LedgerEntryType type;
  final String description;
  final String? referenceId;
  final DateTime createdAt;

  PayoutLedgerEntryModel({
    required this.id,
    required this.amountPaisa,
    required this.type,
    required this.description,
    this.referenceId,
    required this.createdAt,
  });

  Money get amount => Money.fromPaisa(amountPaisa);

  factory PayoutLedgerEntryModel.fromJson(Map<String, dynamic> json) {
    return PayoutLedgerEntryModel(
      id: json['id'] ?? '',
      amountPaisa: json['amountPaisa'] ?? 0,
      type: LedgerEntryType.fromString(json['type']),
      description: json['description'] ?? '',
      referenceId: json['referenceId'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class PayoutBalanceModel {
  final int availableBalancePaisa;
  final int pendingBalancePaisa;
  final int totalDisbursedPaisa;

  PayoutBalanceModel({
    required this.availableBalancePaisa,
    required this.pendingBalancePaisa,
    required this.totalDisbursedPaisa,
  });

  Money get availableBalance => Money.fromPaisa(availableBalancePaisa);
  Money get pendingBalance => Money.fromPaisa(pendingBalancePaisa);
  Money get totalDisbursed => Money.fromPaisa(totalDisbursedPaisa);

  factory PayoutBalanceModel.fromJson(Map<String, dynamic> json) {
    return PayoutBalanceModel(
      availableBalancePaisa: json['availableBalancePaisa'] ?? 0,
      pendingBalancePaisa: json['pendingBalancePaisa'] ?? 0,
      totalDisbursedPaisa: json['totalDisbursedPaisa'] ?? 0,
    );
  }
}
