import 'package:flutter_test/flutter_test.dart';
import 'package:lyrapay/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('appendNumpadDigit basic', () {
      expect(Formatters.appendNumpadDigit('0', '1'), '1');
      expect(Formatters.appendNumpadDigit('1', '2'), '12');
    });

    test('appendNumpadDigit decimal', () {
      expect(Formatters.appendNumpadDigit('1', '.'), '1.');
      expect(Formatters.appendNumpadDigit('1.', '.'), '1.');
      expect(Formatters.appendNumpadDigit('1.2', '3'), '1.23');
      expect(Formatters.appendNumpadDigit('1.234', '5'), '1.234');
    });

    test('appendNumpadDigit max amount', () {
      expect(Formatters.appendNumpadDigit('5000', '1'), '5000');
    });

    test('removeLastNumpadChar', () {
      expect(Formatters.removeLastNumpadChar('123'), '12');
      expect(Formatters.removeLastNumpadChar('1'), '0');
      expect(Formatters.removeLastNumpadChar('0'), '0');
    });
  });
}
