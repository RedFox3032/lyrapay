class LyraTagGenerator {
  static List<String> suggest(String firstName, String lastName) {
    final first = _clean(firstName);
    final last  = _clean(lastName);
    final suggestions = <String>[];

    if (first.isNotEmpty && last.isNotEmpty) {
      suggestions.add('\$first.\$last');
    }

    if (first.length >= 2 && last.length >= 2) {
      suggestions.add('\${first[0]}\$last');
      suggestions.add('\$first\${last[0]}');
      suggestions.add('\${first}_\$last');
    }

    final suffix = DateTime.now().millisecondsSinceEpoch % 1000;
    suggestions.add('\$first\$suffix');

    return suggestions.take(4).toList();
  }

  static String _clean(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .replaceAll(RegExp(r'\s+'), '');
  }
}
