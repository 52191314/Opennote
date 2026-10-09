/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Files in `lib/data` that already imported a page when this test was
/// written. Fix them and shorten this list; do not add to it.
const _knownOffenders = {'lib/data/routes.dart'};

final _pageImport = RegExp(r'''^import\s+['"]package:saber/pages/''');

void main() {
  final offenders = {
    for (final file in _dartFilesIn('lib/data'))
      if (file.readAsLinesSync().any(_pageImport.hasMatch))
        file.path.replaceAll(r'\', '/'),
  };

  test('lib/data does not import from lib/pages', () {
    expect(
      offenders.difference(_knownOffenders),
      isEmpty,
      reason:
          'Data code should not depend on a page. Move what it needs '
          'into lib/data and have the page use it from there.',
    );
  });

  test('every known offender still offends', () {
    expect(
      _knownOffenders.difference(offenders),
      isEmpty,
      reason: 'These files are fixed: remove them from _knownOffenders.',
    );
  });
}

Iterable<File> _dartFilesIn(String directory) => Directory(directory)
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('.dart'));
