import 'package:flutter_test/flutter_test.dart';
import 'package:lyrapay/core/utils/lyra_tag_generator.dart';

void main() {
  test('suggests tags from names', () {
    final suggestions = LyraTagGenerator.suggest('Ahmed', 'Saleh');
    expect(suggestions, isNotEmpty);
    expect(suggestions.any((t) => t.contains('ahmed')), isTrue);
  });
}
