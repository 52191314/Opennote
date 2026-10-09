/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter/material.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/tools/_tool.dart';

/// What the editor's toolbars need to know about the editor,
/// and what they can ask it to do.
///
/// `Toolbar` and `GoodnotesToolbar` lay the same tools out differently,
/// so the editor describes itself to both with one of these.
class EditorToolbarActions {
  const EditorToolbarActions({
    required this.readOnly,
    required this.setTool,
    required this.currentTool,
    required this.setColor,
    required this.quillFocus,
    required this.textEditing,
    required this.toggleTextEditing,
    required this.pickPhoto,
    required this.pickShape,
    required this.paste,
    required this.copySelection,
    required this.pasteSelection,
    required this.duplicateSelection,
    required this.deleteSelection,
    this.cropPossible = false,
    this.cropActive = false,
    this.toggleCrop,
    this.bringToFront,
    this.sendToBack,
    this.smoothen,
    this.addToElements,
    this.openElementsSheet,
    this.onRevealAllTape,
    this.onConcealAllTape,
  });

  /// Whether the note cannot be edited.
  final bool readOnly;

  /// Switches the editor to the given tool.
  final ValueChanged<Tool> setTool;

  /// The tool the editor is using.
  final Tool currentTool;

  /// Gives a colour to the current pen, or to the selection.
  final ValueChanged<Color> setColor;

  /// The text field being typed in, if any.
  final ValueNotifier<QuillStruct?> quillFocus;

  /// Whether the editor is in text editing mode.
  final bool textEditing;

  /// Enters or leaves text editing mode.
  final VoidCallback toggleTextEditing;

  /// Lets the user pick photos to add to the page.
  final VoidCallback pickPhoto;

  /// Lets the user pick a shape to add to the page.
  final VoidCallback pickShape;

  /// Pastes the system clipboard onto the page.
  final VoidCallback paste;

  /// Copies the selection to the editor's own clipboard.
  final VoidCallback copySelection;

  /// Pastes what [copySelection] copied.
  final VoidCallback pasteSelection;

  /// Adds a copy of the selection next to it.
  final VoidCallback duplicateSelection;

  /// Deletes the selection.
  final VoidCallback deleteSelection;

  /// Whether the selection is something that can be cropped.
  final bool cropPossible;

  /// Whether the selection is being cropped.
  final bool cropActive;

  /// Starts or stops cropping the selection.
  final VoidCallback? toggleCrop;

  /// Moves the selection above everything else on the page.
  final VoidCallback? bringToFront;

  /// Moves the selection below everything else on the page.
  final VoidCallback? sendToBack;

  /// Smooths the strokes in the selection.
  final VoidCallback? smoothen;

  /// Saves the selection as a reusable element.
  final VoidCallback? addToElements;

  /// Opens the sheet of saved elements.
  final VoidCallback? openElementsSheet;

  /// Reveals every piece of study tape on the current page.
  final VoidCallback? onRevealAllTape;

  /// Conceals every piece of study tape on the current page.
  final VoidCallback? onConcealAllTape;
}
