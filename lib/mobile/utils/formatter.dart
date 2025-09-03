import 'package:intl/intl.dart';

class Formatter {
  static final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  static final _dateTime = DateFormat('dd MMM yyyy HH:mm');

  static String money(num value) => _currency.format(value);
  static String dateTime(DateTime dt) => _dateTime.format(dt);
}