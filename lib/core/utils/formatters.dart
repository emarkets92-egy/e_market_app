import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');
  static final NumberFormat _numberFormat = NumberFormat.decimalPattern();

  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _dateTimeFormat.format(dateTime);
  }

  static String formatCurrency(double? amount) {
    if (amount == null) return '';
    return _currencyFormat.format(amount);
  }

  static String formatNumber(int? number) {
    if (number == null) return '';
    return _numberFormat.format(number);
  }

  static String formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    // Basic phone formatting - adjust as needed
    return phone;
  }
}

