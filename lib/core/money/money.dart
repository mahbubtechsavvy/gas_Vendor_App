import 'package:intl/intl.dart';

class Money {
  final int paisa;

  const Money(this.paisa);

  factory Money.fromPaisa(int paisa) => Money(paisa);
  factory Money.fromBdt(double bdt) => Money((bdt * 100).round());
  factory Money.fromTaka(double taka) => Money((taka * 100).round());

  static const Money zero = Money(0);

  double get inBdt => paisa / 100.0;
  double get inTaka => inBdt;

  Money operator +(Money other) => Money(paisa + other.paisa);
  Money operator -(Money other) => Money(paisa - other.paisa);
  Money operator *(int factor) => Money(paisa * factor);

  bool operator <(Money other) => paisa < other.paisa;
  bool operator <=(Money other) => paisa <= other.paisa;
  bool operator >(Money other) => paisa > other.paisa;
  bool operator >=(Money other) => paisa >= other.paisa;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Money && runtimeType == other.runtimeType && paisa == other.paisa);

  @override
  int get hashCode => paisa.hashCode;

  String format({bool includeSymbol = true}) {
    final formatter = NumberFormat('#,##,##0.##', 'en_US');
    final formattedNumber = formatter.format(inBdt);
    return includeSymbol ? '৳$formattedNumber' : formattedNumber;
  }

  String formatBangla({bool includeSymbol = true}) {
    final eng = format(includeSymbol: false);
    const engDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bngDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

    String banglaNum = eng;
    for (int i = 0; i < 10; i++) {
      banglaNum = banglaNum.replaceAll(engDigits[i], bngDigits[i]);
    }
    return includeSymbol ? '৳$banglaNum' : banglaNum;
  }

  @override
  String toString() => format();
}
