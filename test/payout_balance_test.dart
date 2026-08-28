import 'package:flutter_test/flutter_test.dart';
import 'package:vendorapp/models/payout_model.dart';

void main() {
  group('Payout Balance & Ledger Model Tests (Integer Paisa)', () {
    test('Parses PayoutBalanceModel accurately', () {
      final json = {
        'availableBalancePaisa': 4500000, // 45,000 BDT
        'pendingBalancePaisa': 500000,    // 5,000 BDT
        'totalDisbursedPaisa': 12000000,  // 120,000 BDT
      };

      final balance = PayoutBalanceModel.fromJson(json);

      expect(balance.availableBalance.paisa, 4500000);
      expect(balance.availableBalance.format(), '৳45,000');
      expect(balance.pendingBalance.format(), '৳5,000');
      expect(balance.totalDisbursed.format(), '৳1,20,000');
    });

    test('Parses PayoutLedgerEntryModel with credit & debit types', () {
      final creditJson = {
        'id': 'ledg-1',
        'amountPaisa': 200000,
        'type': 'CREDIT_ORDER_PAYMENT',
        'description': 'Order Payment GL-20260828-000001',
        'createdAt': '2026-08-28T11:00:00.000Z',
      };

      final debitJson = {
        'id': 'ledg-2',
        'amountPaisa': 50000,
        'type': 'DEBIT_PAYOUT',
        'description': 'Disbursement to bKash 017XXXXXXXX',
        'createdAt': '2026-08-28T12:00:00.000Z',
      };

      final creditEntry = PayoutLedgerEntryModel.fromJson(creditJson);
      final debitEntry = PayoutLedgerEntryModel.fromJson(debitJson);

      expect(creditEntry.type.isCredit, isTrue);
      expect(creditEntry.amount.format(), '৳2,000');

      expect(debitEntry.type.isCredit, isFalse);
      expect(debitEntry.amount.format(), '৳500');
    });
  });
}
