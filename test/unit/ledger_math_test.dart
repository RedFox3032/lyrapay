import 'package:flutter_test/flutter_test.dart';

void main() {
  test('double entry balance', () {
    final balance = 100.0;
    final debit = 30.0;
    expect(balance - debit, 70.0);
  });
}
