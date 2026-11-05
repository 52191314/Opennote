/// 🤖 Generated wholely or partially with Claude Code (Claude Sonnet 5.5)
library;

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/select.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

const _page = HasSize(Size(2000, 2000));

Stroke _stroke(
  List<Offset> points, {
  double size = 4,
  ToolId toolId = ToolId.fountainPen,
}) {
  final stroke = Stroke(
    color: Stroke.defaultColor,
    pressureEnabled: false,
    options: StrokeOptions(size: size),
    pageIndex: 0,
    page: _page,
    toolId: toolId,
  );
  for (final point in points) {
    stroke.addPoint(point);
  }
  return stroke;
}

/// A stroke along the line from [from] to [to], sampled every 5 units.
Stroke _line(Offset from, Offset to, {double size = 4, ToolId? toolId}) {
  final steps = ((to - from).distance / 5).ceil().clamp(2, 1000);
  return _stroke(
    [for (var i = 0; i <= steps; i++) Offset.lerp(from, to, i / steps)!],
    size: size,
    toolId: toolId ?? ToolId.fountainPen,
  );
}

/// Drags a square lasso from [topLeft] with the given [side].
List<Stroke> _lasso(
  List<Stroke> strokes,
  Offset topLeft,
  double side, {
  List<Stroke>? candidates,
}) {
  final select = Select.currentSelect;
  select.onDragStart(topLeft, 0);
  select.onDragUpdate(topLeft + Offset(0, side));
  select.onDragUpdate(topLeft + Offset(side, side));
  select.onDragUpdate(topLeft + Offset(side, 0));
  select.onDragEnd(candidates ?? strokes, const []);
  return select.selectResult.strokes;
}

void main() {
  setUpAll(FlavorConfig.setup);

  setUp(() {
    stows.lassoSelectHandwriting.value = true;
    stows.lassoSelectImages.value = true;
    stows.lassoSelectText.value = true;
    stows.lassoSelectTape.value = true;
    stows.selectionRectMode.value = false;
    stows.lassoSelectPartial.value = true;
    stows.lassoSelectConnected.value = true;
    Select.currentSelect.unselect();
  });

  group('selecting part of a stroke', () {
    test('selects a stroke the lasso only covers the start of', () {
      final stroke = _line(const Offset(50, 50), const Offset(500, 60));

      final selected = _lasso([stroke], Offset.zero, 100);

      expect(selected, [stroke]);
    });

    test('selects a long line crossing the lasso with both ends outside', () {
      final line = _stroke([const Offset(-200, 50), const Offset(400, 50)]);

      final selected = _lasso([line], Offset.zero, 100);

      expect(selected, [line]);
    });

    test('leaves out strokes the lasso does not reach', () {
      final far = _line(const Offset(300, 300), const Offset(500, 400));

      final selected = _lasso([far], Offset.zero, 100);

      expect(selected, isEmpty);
    });

    test('needs the full stroke inside again when switched off', () {
      stows.lassoSelectPartial.value = false;
      final stroke = _line(const Offset(50, 50), const Offset(500, 60));

      final selected = _lasso([stroke], Offset.zero, 100);

      expect(selected, isEmpty);
    });

    test('still honors the handwriting filter', () {
      stows.lassoSelectHandwriting.value = false;
      final stroke = _line(const Offset(50, 50), const Offset(500, 60));

      expect(_lasso([stroke], Offset.zero, 100), isEmpty);
    });
  });

  group('selecting connected strokes', () {
    test('follows a chain of touching strokes out of the lasso', () {
      final inside = _line(const Offset(40, 50), const Offset(120, 50));
      final touching = _line(const Offset(120, 50), const Offset(300, 90));
      final further = _line(const Offset(300, 90), const Offset(300, 400));
      final separate = _line(const Offset(600, 600), const Offset(700, 700));
      final all = [inside, touching, further, separate];

      final selected = _lasso(all, Offset.zero, 100);

      expect(selected, unorderedEquals([inside, touching, further]));
    });

    test('counts strokes that cross as connected', () {
      final horizontal = _line(const Offset(20, 50), const Offset(400, 50));
      final vertical = _line(const Offset(300, -100), const Offset(300, 300));
      final stroke = [horizontal, vertical];

      final selected = _lasso(stroke, Offset.zero, 60);

      expect(selected, unorderedEquals([horizontal, vertical]));
    });

    test('does not join strokes with a visible gap between them', () {
      final inside = _line(const Offset(40, 50), const Offset(120, 50));
      final nearby = _line(const Offset(120, 70), const Offset(300, 70));

      final selected = _lasso([inside, nearby], Offset.zero, 100);

      expect(selected, [inside]);
    });

    test('thick pens connect across a gap their width covers', () {
      final inside = _line(
        const Offset(40, 50),
        const Offset(120, 50),
        size: 30,
      );
      final nearby = _line(
        const Offset(120, 70),
        const Offset(300, 70),
        size: 30,
      );

      final selected = _lasso([inside, nearby], Offset.zero, 100);

      expect(selected, unorderedEquals([inside, nearby]));
    });

    test('does nothing extra when switched off', () {
      stows.lassoSelectConnected.value = false;
      final inside = _line(const Offset(40, 50), const Offset(110, 50));
      final touching = _line(const Offset(110, 50), const Offset(300, 90));

      final selected = _lasso([inside, touching], Offset.zero, 100);

      expect(selected, [inside]);
    });

    test('does not spread through a highlighter laid over the writing', () {
      final word = _line(const Offset(40, 50), const Offset(90, 50));
      final highlight = _line(
        const Offset(0, 50),
        const Offset(600, 50),
        size: 20,
        toolId: ToolId.highlighter,
      );
      final otherWord = _line(const Offset(400, 40), const Offset(450, 60));

      final selected = _lasso(
        [word, highlight, otherWord],
        Offset.zero,
        100,
        candidates: [word, otherWord, highlight],
      );

      expect(selected, contains(word));
      expect(selected, isNot(contains(otherWord)));
    });

    test('does not spread through tape', () {
      final word = _line(const Offset(40, 50), const Offset(90, 50));
      final tape = TapeStroke(
        color: Stroke.defaultColor,
        pressureEnabled: false,
        options: StrokeOptions(),
        pageIndex: 0,
        page: _page,
        toolId: .studyTape,
        rect: const Rect.fromLTWH(0, 40, 600, 30),
      );
      final otherWord = _line(const Offset(400, 40), const Offset(450, 60));

      final selected = _lasso([word, tape, otherWord], Offset.zero, 100);

      expect(selected, isNot(contains(otherWord)));
    });

    test('stays quick on a page full of strokes', () {
      final strokes = [
        for (var row = 0; row < 40; row++)
          for (var column = 0; column < 40; column++)
            _line(
              Offset(column * 30.0, row * 30.0),
              Offset(column * 30.0 + 12, row * 30.0 + 12),
            ),
      ];
      final stopwatch = Stopwatch()..start();

      final selected = _lasso(strokes, const Offset(-5, -5), 40);

      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      expect(selected, isNotEmpty);
      expect(selected.length, lessThan(10));
    });
  });
}
