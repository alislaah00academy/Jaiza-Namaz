// CI guard for 16 §1 (no hard-coded user-facing text) and 16 §2 (RTL-safe
// layout). Run from the repo root: `dart run tool/check_l10n.dart`.
//
// Exits 1 and lists every offending line. Add `// l10n-ignore` at the end of
// a line for a deliberate exception (e.g. a value that is never translated).
import 'dart:io';

/// UI text arguments that must come from ARB.
final _textArg = RegExp(
  r'''(?:\bText\(|\b(?:title|subtitle|label|labelText|hintText|helperText|errorText|tooltip|semanticLabel|message|text)\s*:)\s*(['"])((?:\\.|(?!\1).)*)\1''',
);

/// Layout that doesn't mirror for Urdu: use the Directional variants.
final _rtl = RegExp(
  r'EdgeInsets\.only\([^)]*\b(?:left|right)\s*:'
  r'|\bPositioned\([^)]*\b(?:left|right)\s*:'
  r'|Alignment\.(?:center|top|bottom)(?:Left|Right)\b'
  r'|\bBorder\([^)]*\b(?:left|right)\s*:',
);

/// A letter in any script (Latin or Arabic/Urdu), outside `${...}`.
bool _hasWords(String literal) {
  final withoutInterpolation = literal
      .replaceAll(RegExp(r'\$\{[^}]*\}'), '')
      .replaceAll(RegExp(r'\$\w+'), '');
  return RegExp(r'[A-Za-z؀-ۿ]').hasMatch(withoutInterpolation);
}

void main() {
  final problems = <String>[];

  void scan(String root, {required bool text, required bool rtl}) {
    final dir = Directory(root);
    if (!dir.existsSync()) return;
    for (final f in dir.listSync(recursive: true).whereType<File>()) {
      final path = f.path.replaceAll(r'\', '/');
      if (!path.endsWith('.dart') || path.contains('/gen/')) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final trimmed = line.trimLeft();
        if (trimmed.startsWith('//') || line.contains('l10n-ignore')) continue;
        if (text) {
          for (final m in _textArg.allMatches(line)) {
            if (_hasWords(m.group(2)!)) {
              problems.add('$path:${i + 1}: hard-coded text → move to ARB');
            }
          }
        }
        if (rtl && _rtl.hasMatch(line)) {
          problems.add(
            '$path:${i + 1}: left/right layout → use start/end '
            '(EdgeInsetsDirectional, PositionedDirectional, '
            'AlignmentDirectional, BorderDirectional)',
          );
        }
      }
    }
  }

  // Screens and shared widgets show text; features must also be RTL-safe.
  scan('lib/features', text: true, rtl: true);
  scan('lib/core/widgets', text: true, rtl: false);

  if (problems.isEmpty) {
    stdout.writeln('l10n check: OK');
    return;
  }
  problems.forEach(stderr.writeln);
  stderr.writeln('\nl10n check: ${problems.length} problem(s). See 16 §1–2.');
  exit(1);
}
