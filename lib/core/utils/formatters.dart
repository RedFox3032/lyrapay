import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _lyd = NumberFormat.currency(
    locale: 'ar_LY',
    symbol: 'د.ل',
    decimalDigits: 3,
  );

  static final _lydCompact = NumberFormat.currency(
    locale: 'ar_LY',
    symbol: 'LYD ',
    decimalDigits: 3,
  );

  static String lyd(double amount) => _lyd.format(amount);
  static String lydCompact(double amount) => _lydCompact.format(amount);

  static String numpadDisplay(String rawInput) {
    if (rawInput.isEmpty || rawInput == '0') return '0';
    return rawInput;
  }

  static String appendNumpadDigit(String current, String digit) {
    if (digit == '.' && current.contains('.')) return current;
    if (digit == '.' && current.isEmpty) return '0.';
    if (current == '0' && digit != '.') return digit;
    if (current.contains('.')) {
      final parts = current.split('.');
      if (parts[1].length >= 3) return current;
    }
    final next = current + digit;
    final parsed = double.tryParse(next) ?? 0;
    if (parsed > 5000) return current;
    return next;
  }

  static String removeLastNumpadChar(String current) {
    if (current.isEmpty || current == '0') return '0';
    final result = current.substring(0, current.length - 1);
    return result.isEmpty ? '0' : result;
  }

  static String dateShort(DateTime dt) {
    return DateFormat('MMM d, y').format(dt.toLocal());
  }

  static String timeShort(DateTime dt) {
    return DateFormat('h:mm a').format(dt.toLocal());
  }

  static String dateTime(DateTime dt) {
    return DateFormat('MMM d, y • h:mm a').format(dt.toLocal());
  }

  static String relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '\${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '\${diff.inHours}h ago';
    if (diff.inDays < 7) return '\${diff.inDays}d ago';
    return dateShort(dt);
  }
}
