/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
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

    final topOffset = setShowProtractor != null ? 165.0 : 125.0;

    return IgnorePointer(
      ignoring: effectiveOpacity < 0.5,
      child: AnimatedOpacity(
        opacity: effectiveOpacity,
        duration: const Duration(milliseconds: 200),
        child: Stack(
          children: [
            Positioned(
              top: 5,
              left: 5,
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
              top: 45,
              left: 5,
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
              top: 85,
              left: 5,
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
                top: 125,
                left: 5,
                child: CanvasGestureLockBtn(
                  lock: showProtractor,
                  setLock: setShowProtractor!,
                  icon: showProtractor ? Icons.straighten : Icons.straighten,
                  tooltip: showProtractor
                      ? 'Hide protractor'
                      : 'Show protractor',
                ),
              ),
            Positioned(
              top: topOffset,
              left: 5,
              child: CanvasGestureLockBtn(
                lock: snapGrid,
                setLock: (val) => stows.snapToGrid.value = val,
                icon: snapGrid ? Icons.grid_on : Icons.grid_off,
                tooltip: snapGrid
                    ? 'Disable snap to grid'
                    : 'Enable snap to grid',
              ),
            ),
            Positioned(
              top: topOffset + 40,
              left: 5,
              child: CanvasGestureLockBtn(
                lock: snapAngle,
                setLock: (val) => stows.snapToAngle.value = val,
                icon: snapAngle
                    ? Icons.square_foot
                    : Icons.square_foot_outlined,
                tooltip: snapAngle
                    ? 'Disable snap to angle'
                    : 'Enable snap to angle',
              ),
            ),
            Positioned(
              top: topOffset + 80,
              left: 5,
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
                    color: ColorScheme.of(
                      context,
                    ).surface.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Tooltip(
                    message:
                        'Angle step: ${angleStep == Stows.snapAngleStepIso30 ? "Iso 30°" : "$angleStep°"}',
                    child: Center(
                      child: Text(
                        angleStep == Stows.snapAngleStepIso30
                            ? 'Iso'
                            : '$angleStep°',
                        style: TextStyle(
                          color: ColorScheme.of(context).onSurface,
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
                top: 5,
                right: 50,
                child: CanvasGestureLockBtn(
                  lock: bookmarked,
                  setLock: (_) => onToggleBookmarked!(),
                  icon: bookmarked ? Icons.star : Icons.star_border,
                  tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark page',
                ),
              ),
            Positioned(
              top: 5,
              right: 5,
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
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: ColorScheme.of(
                      context,
                    ).surfaceContainerHighest.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 20),
                        tooltip: 'Reveal all study tape',
                        onPressed: onRevealAllTape,
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility_off, size: 20),
                        tooltip: 'Conceal all study tape',
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
