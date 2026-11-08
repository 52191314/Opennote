/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:saber/components/canvas/hud/canvas_gesture_lock_btn.dart';
import 'package:saber/components/canvas/hud/canvas_zoom_indicator.dart';
import 'package:saber/data/extensions/matrix4_extensions.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:sbn/tool_id.dart';

class CanvasHud extends HookWidget {
  const CanvasHud({
    super.key,
    required this.transformationController,
    required this.zoomLock,
    required this.setZoomLock,
    required this.resetZoom,
    required this.singleFingerPanLock,
    required this.setSingleFingerPanLock,
    required this.axisAlignedPanLock,
    required this.setAxisAlignedPanLock,
    this.showProtractor = false,
    this.setShowProtractor,
    this.bookmarked = false,
    this.onToggleBookmarked,
    this.isDrafting = false,
    this.hasTape = false,
    this.onRevealAllTape,
    this.onConcealAllTape,
    this.isInfiniteCanvas = false,
    this.onFitContent,
  });

  final TransformationController transformationController;
  final bool zoomLock;
  final ValueChanged<bool> setZoomLock;
  final VoidCallback? resetZoom;
  final bool singleFingerPanLock;
  final ValueChanged<bool> setSingleFingerPanLock;
  final bool axisAlignedPanLock;
  final ValueChanged<bool> setAxisAlignedPanLock;
  final bool showProtractor;
  final ValueChanged<bool>? setShowProtractor;
  final bool bookmarked;
  final VoidCallback? onToggleBookmarked;
  final bool isDrafting;
  final bool hasTape;
  final VoidCallback? onRevealAllTape;
  final VoidCallback? onConcealAllTape;
  final bool isInfiniteCanvas;
  final VoidCallback? onFitContent;

  @override
  Widget build(BuildContext context) {
    /// The opacity of the HUD
    final opacity = useState(0.0);

    /// A timer to set the opacity to 0 after inactivity
    final hideTimer = useRef<Timer?>(null);
    useEffect(() => hideTimer.value?.cancel, [hideTimer.value]);

    void onTransform() {
      opacity.value = 1;
      hideTimer.value?.cancel();
      hideTimer.value = Timer(
        const Duration(seconds: 5),
        () => opacity.value = 0,
      );
    }

    useOnListenableChange(transformationController, onTransform);

    final activeTool = useValueListenable(stows.lastTool);
    final snapGrid = useValueListenable(stows.snapToGrid);
    final snapAngle = useValueListenable(stows.snapToAngle);
    final angleStep = useValueListenable(stows.snapAngleStep);

    final isRuler = activeTool == ToolId.ruler;
    final isSnapActive = snapGrid || snapAngle;
    final isDraftingVisible = isDrafting || isRuler || isSnapActive;
    final effectiveOpacity = isDraftingVisible ? 1.0 : opacity.value;

    final colorScheme = ColorScheme.of(context);
    final isGoodnotesUi = useValueListenable(stows.goodnotesUiMode);
    final topPadding = MediaQuery.paddingOf(context).top;
    final baseTop = isGoodnotesUi ? (topPadding + 54.0 + 8.0) : 4.0;
    final topOffset = setShowProtractor != null ? 168.0 : 128.0;
    final railHeight = topOffset + 114.0;

    return IgnorePointer(
      ignoring: effectiveOpacity < 0.5,
      child: AnimatedOpacity(
        opacity: effectiveOpacity,
        duration: const Duration(milliseconds: 200),
        child: Stack(
          children: [
            // Sleek vertical floating Studio HUD pill backdrop
            Positioned(
              top: baseTop,
              left: 4,
              child: IgnorePointer(
                child: Container(
                  width: 42,
                  height: railHeight,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow.withValues(
                      alpha: 0.72,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: baseTop + 4,
              left: 8,
              child: CanvasGestureLockBtn(
                lock: zoomLock,
                setLock: setZoomLock,
                icon: zoomLock ? Icons.lock : Icons.lock_open,
                tooltip: zoomLock
                    ? t.editor.hud.unlockZoom
                    : t.editor.hud.lockZoom,
              ),
            ),
            Positioned(
              top: baseTop + 44,
              left: 8,
              child: CanvasGestureLockBtn(
                lock: singleFingerPanLock,
                setLock: setSingleFingerPanLock,
                icon: singleFingerPanLock ? Icons.pinch : Icons.swipe_up,
                tooltip: singleFingerPanLock
                    ? t.editor.hud.unlockSingleFingerPan
                    : t.editor.hud.lockSingleFingerPan,
              ),
            ),
            Positioned(
              top: baseTop + 84,
              left: 8,
              child: CanvasGestureLockBtn(
                lock: axisAlignedPanLock,
                setLock: setAxisAlignedPanLock,
                tooltip: axisAlignedPanLock
                    ? t.editor.hud.unlockAxisAlignedPan
                    : t.editor.hud.lockAxisAlignedPan,
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: axisAlignedPanLock ? 0 : 1 / 8,
                  child: const Icon(Symbols.drag_pan),
                ),
              ),
            ),
            if (setShowProtractor != null)
              Positioned(
                top: baseTop + 124,
                left: 8,
                child: CanvasGestureLockBtn(
                  lock: showProtractor,
                  setLock: setShowProtractor!,
                  icon: showProtractor ? Icons.straighten : Icons.straighten,
                  tooltip: showProtractor
                      ? t.editor.canvasHud.hideProtractor
                      : t.editor.canvasHud.showProtractor,
                ),
              ),
            Positioned(
              top: baseTop + topOffset,
              left: 8,
              child: CanvasGestureLockBtn(
                lock: snapGrid,
                setLock: (val) => stows.snapToGrid.value = val,
                icon: snapGrid ? Icons.grid_on : Icons.grid_off,
                tooltip: snapGrid
                    ? t.editor.canvasHud.disableSnapToGrid
                    : t.editor.canvasHud.enableSnapToGrid,
              ),
            ),
            Positioned(
              top: baseTop + topOffset + 40,
              left: 8,
              child: CanvasGestureLockBtn(
                lock: snapAngle,
                setLock: (val) => stows.snapToAngle.value = val,
                icon: snapAngle
                    ? Icons.square_foot
                    : Icons.square_foot_outlined,
                tooltip: snapAngle
                    ? t.editor.canvasHud.disableSnapToAngle
                    : t.editor.canvasHud.enableSnapToAngle,
              ),
            ),
            Positioned(
              top: baseTop + topOffset + 80,
              left: 8,
              child: GestureDetector(
                onTap: () {
                  final cur = angleStep;
                  if (cur == 15) {
                    stows.snapAngleStep.value = 30;
                  } else if (cur == 30) {
                    stows.snapAngleStep.value = 45;
                  } else if (cur == 45) {
                    stows.snapAngleStep.value = Stows.snapAngleStepIso30;
                  } else {
                    stows.snapAngleStep.value = 15;
                  }
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: snapAngle
                        ? colorScheme.primaryContainer.withValues(alpha: 0.92)
                        : colorScheme.surface.withValues(alpha: 0.85),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    border: Border.all(
                      color: snapAngle
                          ? colorScheme.primary.withValues(alpha: 0.6)
                          : colorScheme.outlineVariant.withValues(alpha: 0.55),
                      width: 1,
                    ),
                  ),
                  child: Tooltip(
                    message: t.editor.canvasHud.angleStep(
                      step: angleStep == Stows.snapAngleStepIso30
                          ? t.editor.canvasHud.iso30
                          : '$angleStep°',
                    ),
                    child: Center(
                      child: Text(
                        angleStep == Stows.snapAngleStepIso30
                            ? t.editor.canvasHud.iso
                            : '$angleStep°',
                        style: TextStyle(
                          color: snapAngle
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (onToggleBookmarked != null)
              Positioned(
                top: baseTop + 4,
                right: 60,
                child: CanvasGestureLockBtn(
                  lock: bookmarked,
                  setLock: (_) => onToggleBookmarked!(),
                  icon: bookmarked ? Icons.star : Icons.star_border,
                  tooltip: bookmarked
                      ? t.editor.bookmark.remove
                      : t.editor.bookmark.add,
                ),
              ),
            if (isInfiniteCanvas && onFitContent != null)
              Positioned(
                top: baseTop + 4,
                right: onToggleBookmarked != null ? 102 : 60,
                child: CanvasGestureLockBtn(
                  lock: false,
                  setLock: (_) => onFitContent!(),
                  icon: Icons.fit_screen_rounded,
                  tooltip: t.editor.canvasHud.fitContent,
                ),
              ),
            Positioned(
              top: baseTop + 4,
              right: 8,
              child: AnimatedBuilder(
                animation: transformationController,
                builder: (context, _) => CanvasZoomIndicator(
                  scale: transformationController.value.approxScale,
                  resetZoom: resetZoom,
                ),
              ),
            ),
            if (hasTape && onRevealAllTape != null && onConcealAllTape != null)
              Positioned(
                bottom: 24,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow.withValues(
                      alpha: 0.92,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.55),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.visibility, size: 20),
                        tooltip: t.editor.tape.revealAllTooltip,
                        onPressed: onRevealAllTape,
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.visibility_off, size: 20),
                        tooltip: t.editor.tape.concealAllTooltip,
                        onPressed: onConcealAllTape,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
