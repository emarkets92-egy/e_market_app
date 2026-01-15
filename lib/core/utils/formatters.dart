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

  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      // For older messages, show date
      final dateFormat = DateFormat('MMM d');
      if (dateTime.year != now.year) {
        return DateFormat('MMM d, yyyy').format(dateTime);
      }
      return dateFormat.format(dateTime);
    }
  }
}
