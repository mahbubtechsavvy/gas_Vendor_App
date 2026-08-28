import 'package:flutter_test/flutter_test.dart';
import 'package:vendorapp/core/money/money.dart';

void main() {
  group('Money Value Object Tests (Integer Paisa)', () {
    test('Constructs from paisa accurately', () {
      final m = Money.fromPaisa(125000); // 1250 Taka
      expect(m.paisa, 125000);
      expect(m.inTaka, 1250.0);
    });

    test('Constructs from taka accurately', () {
      final m = Money.fromTaka(1450.50);
      expect(m.paisa, 145050);
    });

    test('English formatting produces proper comma separation', () {
      final m = Money.fromPaisa(125000);
      expect(m.format(), '৳1,250');
      expect(m.format(includeSymbol: false), '1,250');
    });

    test('Bangla formatting translates numerals to Bengali digits', () {
      final m = Money.fromPaisa(125000);
      expect(m.formatBangla(), '৳১,২৫০');
      expect(m.formatBangla(includeSymbol: false), '১,২৫০');
    });

    test('Arithmetic operations preserve integer precision', () {
      final m1 = Money.fromPaisa(100000);
      final m2 = Money.fromPaisa(50000);

      expect((m1 + m2).paisa, 150000);
      expect((m1 - m2).paisa, 50000);
      expect((m1 * 2).paisa, 200000);
    });
  });
}
