/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:sbn/tool_id.dart';

/// A tool for placing [TapeStroke] masking tape strips on notes for active recall.
class StudyTapeTool extends Pen {
  StudyTapeTool({
    TapePattern? pattern,
    super.color = const Color(0xFFFFD54F),
  })  : pattern = pattern ?? defaultPattern,
        super(
          name: 'Study Tape',
          sizeMin: 10,
          sizeMax: 60,
          sizeStep: 5,
          icon: studyTapeIcon,
          options: StrokeOptions(size: 24, isComplete: false),
          pressureEnabled: false,
          toolId: ToolId.studyTape,
        );

  static const studyTapeIcon = Icons.view_headline_rounded;

  static TapePattern get defaultPattern {
    return switch (stows.studyTapePattern.value) {
      'stripes' => TapePattern.stripes,
      'dots' => TapePattern.dots,
      'grid' => TapePattern.grid,
      _ => TapePattern.solid,
    };
  }

  TapePattern pattern;

  static final currentStudyTape = StudyTapeTool();

  Offset? _dragStart;

  @override
  void onDragStart(
    Offset position,
    EditorPage page,
    int pageIndex,
    double? pressure,
  ) {
    _dragStart = position;
    final initialRect = Rect.fromCenter(
      center: position,
      width: 4,
      height: options.size,
    );
    Pen.currentStroke = TapeStroke(
      color: color,
      pressureEnabled: false,
      options: options.copyWith(isComplete: false),
      pageIndex: pageIndex,
      page: page,
      toolId: toolId,
      rect: initialRect,
      isConcealed: true,
      pattern: pattern,
    );
  }

  @override
  void onDragUpdate(Offset position, double? pressure) {
    if (_dragStart == null || Pen.currentStroke is! TapeStroke) return;

    final start = _dragStart!;
    final stroke = Pen.currentStroke as TapeStroke;

    final dx = position.dx - start.dx;
    final dy = position.dy - start.dy;
    final minHeight = options.size;

    final left = min(start.dx, position.dx);
    final top = min(start.dy, position.dy);
    final width = max(dx.abs(), 10.0);
    final height = max(dy.abs(), minHeight);

    // If drag is mostly horizontal (covering lines of text), center vertically around the drag
    if (dx.abs() > dy.abs() * 1.5) {
      final centerY = (start.dy + position.dy) / 2;
      stroke.rect = Rect.fromCenter(
        center: Offset(left + width / 2, centerY),
        width: width,
        height: minHeight,
      );
    } else {
      stroke.rect = Rect.fromLTWH(left, top, width, height);
    }
  }

  @override
  Stroke? onDragEnd() {
    final stroke = Pen.currentStroke;
    _dragStart = null;

    if (stroke is! TapeStroke) {
      return super.onDragEnd();
    }

    stroke.options.isComplete = true;
    Pen.currentStroke = null;
    return stroke;
  }
}
