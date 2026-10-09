/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/page_templates.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/study_tape.dart';
import 'package:sbn/canvas_background_pattern.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

class _FakePage implements HasSize {
  @override
  var size = const Size(1000, 1000);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  group('Study Tape Stroke & Tool', () {
    test('TapeStroke initializes with default concealed state', () {
      final page = _FakePage();
      final tape = TapeStroke(
        color: const Color(0xFFFFD54F),
        pressureEnabled: false,
        options: StrokeOptions(size: 24),
        pageIndex: 0,
        page: page,
        toolId: ToolId.studyTape,
        rect: const Rect.fromLTWH(50, 100, 200, 30),
      );

      expect(tape.isConcealed, isTrue);
      expect(tape.rect.width, equals(200));
      expect(tape.rect.height, equals(30));
      expect(tape.toolId, equals(ToolId.studyTape));

      tape.toggleConceal();
      expect(tape.isConcealed, isFalse);
      tape.toggleConceal();
      expect(tape.isConcealed, isTrue);
    });

    test('TapeStroke serializes to JSON and deserializes correctly', () {
      final page = _FakePage();
      final tape = TapeStroke(
        color: const Color(0xFFFF80AB),
        pressureEnabled: false,
        options: StrokeOptions(size: 20),
        pageIndex: 1,
        page: page,
        toolId: ToolId.studyTape,
        rect: const Rect.fromLTWH(10, 20, 150, 25),
        isConcealed: false,
      );

      final json = tape.toJson();
      expect(json['shape'], equals('tape'));
      expect(json['c_state'], isFalse);
      expect(json['rl'], equals(10.0));
      expect(json['rt'], equals(20.0));
      expect(json['rw'], equals(150.0));
      expect(json['rh'], equals(25.0));

      final roundtrip = Stroke.fromJson(
        json,
        fileVersion: 19,
        pageIndex: 1,
        page: page,
      );

      expect(roundtrip, isA<TapeStroke>());
      final tapeRoundtrip = roundtrip as TapeStroke;
      expect(tapeRoundtrip.isConcealed, isFalse);
      expect(tapeRoundtrip.rect.left, equals(10.0));
      expect(tapeRoundtrip.rect.width, equals(150.0));
      expect(
        tapeRoundtrip.color.toARGB32(),
        equals(const Color(0xFFFF80AB).toARGB32()),
      );
    });

    test('StudyTapeTool drag lifecycle constructs TapeStroke', () {
      final page = EditorPage(size: const Size(800, 1200));

      final tool = StudyTapeTool();
      expect(tool.toolId, equals(ToolId.studyTape));

      tool.onDragStart(const Offset(100, 100), page, 0, null);
      expect(Pen.currentStroke, isA<TapeStroke>());

      tool.onDragUpdate(const Offset(300, 100), null);
      final tape = Pen.currentStroke as TapeStroke;
      expect(tape.rect.width, equals(200));

      final result = tool.onDragEnd();
      expect(result, isA<TapeStroke>());
      expect((result as TapeStroke).rect.width, equals(200));
      expect(Pen.currentStroke, isNull);
    });

    test('ToolIdZIndex ordering ensures proper layering', () {
      expect(ToolId.highlighter.zIndex, equals(0));
      expect(ToolId.ballpointPen.zIndex, equals(1));
      expect(ToolId.fountainPen.zIndex, equals(1));
      expect(ToolId.studyTape.zIndex, equals(2));
    });
  });

  group('Paper Templates & Styling', () {
    test('PageTemplate includes Cornell and Cream color presets', () {
      final cornellCream = PageTemplate.all.firstWhere(
        (t) => t.name == 'Cornell Notes (Cream)',
      );
      expect(
        cornellCream.backgroundPattern,
        equals(CanvasBackgroundPattern.cornell),
      );
      expect(
        cornellCream.backgroundColor,
        equals(PageTemplate.paperColorWarmCream),
      );

      final legalPad = PageTemplate.all.firstWhere(
        (t) => t.name == 'Legal Pad (Yellow)',
      );
      expect(legalPad.backgroundPattern, equals(CanvasBackgroundPattern.lined));
      expect(legalPad.backgroundColor, equals(PageTemplate.paperColorLegalPad));
    });
  });
}
