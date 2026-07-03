/// 🤖 Generated with DeepSeek v4 Flash
library;

import 'package:sbn/canvas_background_pattern.dart';

/// A pre-made page layout that sets the background pattern, line height,
/// line thickness, and optionally inserts initial Quill content.
class PageTemplate {
  /// Creates a new page template.
  ///
  /// [name] is the display name shown to the user.
  /// [backgroundPattern] is the pattern applied to the page canvas.
  /// [lineHeight] defaults to 40 (pixels between lines).
  /// [lineThickness] defaults to 3 (pixels wide).
  /// [initialContent] is optional text inserted into the Quill editor
  /// when the template is applied (used for planners, to-do lists, etc.).
  const PageTemplate({
    required this.name,
    required this.backgroundPattern,
    this.lineHeight = 40,
    this.lineThickness = 3,
    this.initialContent,
  });

  /// Display name shown to the user.
  final String name;

  /// The background pattern applied to the page canvas.
  final CanvasBackgroundPattern backgroundPattern;

  /// Line height in pixels (controls spacing between grid/lines and text size).
  final int lineHeight;

  /// Line thickness in pixels.
  final int lineThickness;

  /// Optional text content inserted into the Quill editor.
  /// When non-null, this plain text is prepended to the current document.
  /// Use `\n` for line breaks.
  final String? initialContent;

  /// All built-in templates available to the user.
  static const all = <PageTemplate>[
    PageTemplate(
      name: 'Blank',
      backgroundPattern: CanvasBackgroundPattern.none,
    ),
    PageTemplate(
      name: 'Lined',
      backgroundPattern: CanvasBackgroundPattern.lined,
    ),
    PageTemplate(
      name: 'Grid',
      backgroundPattern: CanvasBackgroundPattern.grid,
    ),
    PageTemplate(
      name: 'Dot Grid',
      backgroundPattern: CanvasBackgroundPattern.dots,
    ),
    PageTemplate(
      name: 'College Ruled',
      backgroundPattern: CanvasBackgroundPattern.collegeLtr,
      lineHeight: 30,
    ),
    PageTemplate(
      name: 'Cornell Notes',
      backgroundPattern: CanvasBackgroundPattern.cornell,
    ),
    PageTemplate(
      name: 'Engineering Grid',
      backgroundPattern: CanvasBackgroundPattern.engineeringGrid,
    ),
    PageTemplate(
      name: 'Isometric',
      backgroundPattern: CanvasBackgroundPattern.isometric,
    ),
    PageTemplate(
      name: 'Planner (Weekly)',
      backgroundPattern: CanvasBackgroundPattern.grid,
      initialContent: 'Weekly Planner\n'
          '----------------------\n'
          '\n'
          'Monday:\n'
          '  - \n'
          '  - \n'
          '\n'
          'Tuesday:\n'
          '  - \n'
          '  - \n'
          '\n'
          'Wednesday:\n'
          '  - \n'
          '  - \n'
          '\n'
          'Thursday:\n'
          '  - \n'
          '  - \n'
          '\n'
          'Friday:\n'
          '  - \n'
          '  - \n'
          '\n'
          'Weekend:\n'
          '  - \n'
          '  - \n',
    ),
    PageTemplate(
      name: 'To-Do List',
      backgroundPattern: CanvasBackgroundPattern.lined,
      initialContent: 'To-Do List\n'
          '-------------\n'
          '\n'
          '- [ ] \n'
          '- [ ] \n'
          '- [ ] \n'
          '- [ ] \n'
          '- [ ] \n'
          '\n'
          '- [ ] \n'
          '- [ ] \n'
          '- [ ] \n',
    ),
  ];
}
