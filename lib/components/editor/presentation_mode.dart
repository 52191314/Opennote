/// 🤖 Modified with DeepSeek v4 Flash
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saber/components/canvas/inner_canvas.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';

enum DisplayMode {
  /// Classic presentation mode: pages fill the screen, controls on middle tap.
  presentation,

  /// Study mode: pages shown one at a time as flashcards.
  /// Content is hidden initially; tap to reveal.
  /// Track which pages have been studied.
  flashcard,
}

/// A full-screen mode that displays one page at a time,
/// centered and fitted to the screen, with tap/swipe/keyboard navigation.
///
/// Supports two modes:
/// - [DisplayMode.presentation]: Present notes on a projector or external display.
/// - [DisplayMode.flashcard]: Study notes with a "flip to reveal" interaction.
///
/// All editing is disabled; this is a read-only view.
class PresentationMode extends StatefulWidget {
  const PresentationMode({
    super.key,
    required this.coreInfo,
    this.initialPageIndex = 0,
    this.mode = DisplayMode.presentation,
  });

  final EditorCoreInfo coreInfo;
  final int initialPageIndex;
  final DisplayMode mode;

  @override
  State<PresentationMode> createState() => _PresentationModeState();
}

class _PresentationModeState extends State<PresentationMode>
    with SingleTickerProviderStateMixin {
  late int _currentPageIndex;
  late final int _totalPages;
  var _showControls = true;

  // Flashcard-specific state
  final Set<int> _studiedPageIndices = {};
  var _isFlipped = false;
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPageIndex
        .clamp(0, widget.coreInfo.pages.length - 1);
    _totalPages = widget.coreInfo.pages.length;

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  bool get _isFlashcardMode => widget.mode == DisplayMode.flashcard;

  EditorPage get _currentPage => widget.coreInfo.pages[_currentPageIndex];

  bool get _canGoPrevious => _currentPageIndex > 0;
  bool get _canGoNext => _currentPageIndex < _totalPages - 1;

  int get _studiedCount => _studiedPageIndices.length;

  void _previousPage() {
    if (!_canGoPrevious) return;
    setState(() {
      _currentPageIndex--;
      _isFlipped = false;
    });
    if (_isFlashcardMode) _flipController.reverse();
  }

  void _nextPage() {
    if (!_canGoNext) return;
    setState(() {
      _currentPageIndex++;
      _isFlipped = false;
    });
    if (_isFlashcardMode) _flipController.reverse();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  void _exitFullscreen() {
    Navigator.of(context).pop();
  }

  void _resetStudyProgress() {
    setState(() => _studiedPageIndices.clear());
  }

  void _toggleFlip() {
    if (!_isFlashcardMode) return;
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _markStudied(bool known) {
    if (!_isFlashcardMode) return;
    setState(() {
      _studiedPageIndices.add(_currentPageIndex);
    });
    _nextPage();
  }

  @override
  Widget build(BuildContext context) {
    final page = _currentPage;

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Page content, centered and fitted to screen
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _isFlashcardMode && !_isFlipped
                    ? _buildCardBack()
                    : FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: page.size.width,
                          height: page.size.height,
                          child: InnerCanvas(
                            pageIndex: _currentPageIndex,
                            redrawPageListenable: page,
                            width: page.size.width,
                            height: page.size.height,
                            showPageIndicator: false,
                            coreInfo: widget.coreInfo,
                            currentStroke: null,
                            currentStrokeDetectedShape: null,
                            currentSelection: null,
                            currentToolIsSelect: false,
                            currentScale: double.maxFinite,
                          ),
                        ),
                      ),
              ),
            ),

            // Controls overlay
            if (_showControls) ...[
              // Exit button — top-right corner
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  tooltip: _isFlashcardMode
                      ? 'Exit flashcards (Esc)'
                      : 'Exit presentation (Esc)',
                  onPressed: _exitFullscreen,
                ),
              ),

              // Reset button (flashcard mode only) — top-left corner
              if (_isFlashcardMode)
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                    tooltip: 'Reset study progress',
                    onPressed: _resetStudyProgress,
                  ),
                ),

              // Page / progress indicator — bottom center
              Positioned(
                bottom: _isFlashcardMode ? 96 : 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isFlashcardMode
                          ? 'Flashcard ${_currentPageIndex + 1} / $_totalPages  ·  $_studiedCount studied'
                          : '${_currentPageIndex + 1} / $_totalPages',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              // Flashcard rating buttons — bottom area
              if (_isFlashcardMode && _isFlipped) ...[
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FlashcardButton(
                        icon: Icons.close,
                        label: "Don't Know",
                        color: Colors.redAccent,
                        onPressed: () => _markStudied(false),
                      ),
                      const SizedBox(width: 24),
                      _FlashcardButton(
                        icon: Icons.check,
                        label: 'Know',
                        color: Colors.greenAccent,
                        onPressed: () => _markStudied(true),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            // Tap zones — full screen
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: _isFlashcardMode ? _handleFlashcardTap : _handleTap,
                onHorizontalDragEnd: _handleSwipe,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * math.pi;
        // Use a perspective transform for the flip effect
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: angle < math.pi / 2
              ? child
              : child, // keeps widget alive during flip
        );
      },
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A3E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories,
              size: 64,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'Flashcard ${_currentPageIndex + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap to reveal',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
            if (_studiedPageIndices.contains(_currentPageIndex)) ...[
              const SizedBox(height: 24),
              Icon(
                Icons.check_circle,
                size: 28,
                color: Colors.greenAccent.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.pageUp:
        _previousPage();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.pageDown:
        _nextPage();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.escape:
        _exitFullscreen();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.space:
        if (_isFlashcardMode) {
          _toggleFlip();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;

      default:
        return KeyEventResult.ignored;
    }
  }

  void _handleTap(TapUpDetails details) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final tapX = details.localPosition.dx;

    if (tapX < screenWidth / 3) {
      // Left third → previous page
      _previousPage();
    } else if (tapX > screenWidth * 2 / 3) {
      // Right third → next page
      _nextPage();
    } else {
      // Middle third → toggle controls
      _toggleControls();
    }
  }

  void _handleFlashcardTap(TapUpDetails details) {
    if (!_isFlipped) {
      // Tap anywhere when face-down → flip to reveal
      _toggleFlip();
    } else {
      // When face-up, left/right thirds navigate
      final screenWidth = MediaQuery.sizeOf(context).width;
      final tapX = details.localPosition.dx;

      if (tapX < screenWidth / 3) {
        _previousPage();
      } else if (tapX > screenWidth * 2 / 3) {
        _nextPage();
      }
      // Middle third → no action (buttons are below)
    }
  }

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity;
    if (velocity == null) return;

    if (velocity < -50) {
      // Swipe left → next page
      _nextPage();
    } else if (velocity > 50) {
      // Swipe right → previous page
      _previousPage();
    }
  }
}

/// A styled button used in flashcard mode for "Know" / "Don't Know" ratings.
class _FlashcardButton extends StatelessWidget {
  const _FlashcardButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: color.withValues(alpha: 0.15),
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
