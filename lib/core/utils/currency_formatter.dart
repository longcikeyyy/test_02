import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');

String formatCurrency(num value) => _currency.format(value);
