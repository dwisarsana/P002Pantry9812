class SafePromptFilterResult {
  const SafePromptFilterResult({
    required this.allowed,
    this.reason,
    required this.sanitized,
  });

  final bool allowed;
  final String? reason;
  final String sanitized;
}

class SafePromptFilter {
  SafePromptFilter({this.mode = 'relaxed'});

  final String mode;
  static const _blocked = ['nsfw', 'nudity', 'explicit'];

  SafePromptFilterResult check(String prompt) {
    final lower = prompt.toLowerCase();
    for (final word in _blocked) {
      if (lower.contains(word)) {
        return SafePromptFilterResult(
          allowed: false,
          reason: word,
          sanitized: prompt,
        );
      }
    }
    return SafePromptFilterResult(
      allowed: true,
      sanitized: prompt.trim(),
    );
  }
}
