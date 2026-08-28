import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/payout_model.dart';

class PayoutProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  PayoutBalanceModel? _balance;
  List<PayoutLedgerEntryModel> _ledgerEntries = [];
  bool _isLoading = false;
  String? _error;

  PayoutBalanceModel? get balance => _balance;
  List<PayoutLedgerEntryModel> get ledgerEntries => _ledgerEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPayoutData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final balanceRes = await _client.get(ApiEndpoints.payoutBalance);
      _balance = PayoutBalanceModel.fromJson(balanceRes);

      final ledgerRes = await _client.get(ApiEndpoints.payoutLedger);
      if (ledgerRes is List) {
        _ledgerEntries = ledgerRes.map((e) => PayoutLedgerEntryModel.fromJson(e)).toList();
      } else if (ledgerRes is Map<String, dynamic> && ledgerRes['entries'] is List) {
        _ledgerEntries = (ledgerRes['entries'] as List)
            .map((e) => PayoutLedgerEntryModel.fromJson(e))
            .toList();
      }

      _ledgerEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> requestPayout({
    required int amountPaisa,
    required String paymentMethod,
    required String accountDetails,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.post(
        ApiEndpoints.requestPayout,
        body: {
          'amountPaisa': amountPaisa,
          'method': paymentMethod,
          'accountDetails': accountDetails,
        },
      );
      await fetchPayoutData();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
