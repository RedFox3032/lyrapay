import 'package:flutter_test/flutter_test.dart';
import 'package:lyrapay/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email validation', () {
      expect(Validators.email(null), 'Email is required');
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email('test@example.com'), isNull);
      expect(Validators.email('invalid'), 'Enter a valid email address');
    });

    test('password validation', () {
      expect(Validators.password('short'), 'Password must be at least 8 characters');
      expect(Validators.password('longenough1'), 'Must contain an uppercase letter');
      expect(Validators.password('Longenough1'), isNull);
    });

    test('pin validation', () {
      expect(Validators.pin('123'), 'PIN must be 4 digits');
      expect(Validators.pin('1234'), isNull);
      expect(Validators.pin('abcd'), 'PIN must contain only digits');
    });

    test('lyraTag validation', () {
      expect(Validators.lyraTag('ab'), 'Must be at least 4 characters');
      expect(Validators.lyraTag('valid.tag'), isNull);
    });
  });
}
