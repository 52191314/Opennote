/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Widget code written for Opennote, which must take its text from
/// `lib/i18n/en.i18n.yaml` so that it can be translated.
const _translatedSources = [
  'lib/components/canvas/canvas_image_dialog.dart',
  'lib/components/canvas/hud',
  'lib/components/canvas/lasso_callout_menu.dart',
  'lib/components/canvas/lasso_screenshot_dialog.dart',
  'lib/components/editor',
  'lib/components/onboarding',
  'lib/components/toolbar',
];

/// Text that is the same in every language.
const _untranslatable = {'A4', 'PDF', 'SBA'};

/// A widget argument or `Text` whose value is an English string literal,
/// e.g. `tooltip: 'Add Layer'` or `Text('Layers')`.
final _hardcodedLabel = RegExp(
  r'''(?:\bText\(|\b(?:tooltip|label|labelText|hintText|title|subtitle|message|semanticLabel):)\s*(?:const\s+Text\(\s*)?(['"])([A-Z][^'"$]*)\1''',
);

void main() {
  test('Opennote widgets take their text from the translation files', () {
    final hardcoded = <String>[];
    for (final file in _dartFiles()) {
      final lines = file.readAsLinesSync();
      for (final (index, line) in lines.indexed) {
        final match = _hardcodedLabel.firstMatch(line);
        if (match == null) continue;
        if (_untranslatable.contains(match[2])) continue;
        hardcoded.add('${file.path}:${index + 1}: ${line.trim()}');
      }
    }

    expect(
      hardcoded,
      isEmpty,
      reason:
          'Add these strings to lib/i18n/en.i18n.yaml, run `dart run slang`, '
          'and use `t.` to read them.',
    );
  });
}

Iterable<File> _dartFiles() sync* {
  for (final source in _translatedSources) {
    if (FileSystemEntity.isFileSync(source)) {
      yield File(source);
      continue;
    }
    yield* Directory(source)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
  }
}
