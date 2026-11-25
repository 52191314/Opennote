/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:saber/components/canvas/save_indicator.dart';

/// Prevents navigating away from the editor until pending changes are saved.
class EditorSavePopScope extends StatelessWidget {
  /// Creates an [EditorSavePopScope].
  const EditorSavePopScope({
    super.key,
    required this.savingState,
    required this.onTriggerSave,
    required this.onNeedsSaveNotice,
    required this.child,
  });

  /// Observable save status for the current note.
  final ValueListenable<SavingState> savingState;

  /// Triggers an immediate save when a pop is blocked in `waitingToSave`.
  final VoidCallback onTriggerSave;

  /// Notifies the user that saving must finish before exiting.
  final VoidCallback onNeedsSaveNotice;

  /// Editor scaffold subtree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SavingState>(
      valueListenable: savingState,
      builder: (context, state, child) => PopScope(
        canPop: state == SavingState.saved,
        onPopInvokedWithResult: (didPop, _) {
          switch (state) {
            case SavingState.waitingToSave:
              assert(!didPop);
              onTriggerSave();
              onNeedsSaveNotice();
            case SavingState.saving:
              assert(!didPop);
              onNeedsSaveNotice();
            case SavingState.saved:
              break;
          }
        },
        child: child!,
      ),
      child: child,
    );
  }
}
