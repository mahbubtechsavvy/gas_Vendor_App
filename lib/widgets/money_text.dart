import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/i18n/locale_provider.dart';
import '../core/money/money.dart';

class MoneyText extends StatelessWidget {
  final Money money;
  final TextStyle? style;
  final bool includeSymbol;

  const MoneyText({
    super.key,
    required this.money,
    this.style,
    this.includeSymbol = true,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final formatted = loc.isBangla
        ? money.formatBangla(includeSymbol: includeSymbol)
        : money.format(includeSymbol: includeSymbol);

    return Text(
      formatted,
      style: style,
    );
  }
}
