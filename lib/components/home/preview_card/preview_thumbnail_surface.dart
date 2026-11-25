/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/inner_canvas.dart';
import 'package:saber/components/canvas/invert_widget.dart';
import 'package:saber/components/home/preview_card/preview_thumbnail_state.dart';
import 'package:saber/data/extensions/color_extensions.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';

/// Renders the thumbnail surface of a notebook preview card, including dark
/// mode auto-inversion and the tactile fallback notebook cover.
class PreviewThumbnailSurface extends StatelessWidget {
  const PreviewThumbnailSurface({
    super.key,
    required this.filePath,
    required this.thumbnail,
    required this.invert,
    required this.cardRadius,
    required this.borderWidth,
  });

  final String filePath;
  final PreviewThumbnailState thumbnail;
  final bool invert;
  final double cardRadius;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final innerRadius = BorderRadius.only(
      topLeft: Radius.circular(cardRadius - borderWidth),
      topRight: Radius.circular(cardRadius - borderWidth),
    );

    return Stack(
      children: [
        Positioned.fill(
          top: cardRadius,
          left: borderWidth,
          right: borderWidth,
          child: ColoredBox(
            color: InnerCanvas.defaultBackgroundColor.withInversion(invert),
          ),
        ),
        ListenableBuilder(
          listenable: thumbnail,
          builder: (context, _) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: ConstrainedBox(
              key: ValueKey(thumbnail.updateCount),
              constraints: const BoxConstraints(
                minWidth: double.infinity,
                minHeight: 124,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: borderWidth,
                  left: borderWidth,
                  right: borderWidth,
                ),
                child: ClipRRect(
                  borderRadius: innerRadius,
                  child: InvertWidget(
                    invert: invert,
                    child: thumbnail.doesImageExist
                        ? Image(
                            image: thumbnail.image!,
                            alignment: Alignment.topCenter,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          )
                        : PreviewFallbackCover(
                            filePath: filePath,
                            topRadius: cardRadius - borderWidth,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tactile notebook cover displayed when a note has not yet generated a
/// thumbnail preview image.
class PreviewFallbackCover extends StatelessWidget {
  const PreviewFallbackCover({super.key, this.filePath, this.topRadius = 12.0});

  final String? filePath;
  final double topRadius;

  static const _coverPalette = <Color>[
    Color(0xFF2B4C7E), // Ink Navy
    Color(0xFF2E6F56), // Forest Sage
    Color(0xFF8C3A3A), // Wine Burgundy
    Color(0xFF6B4E84), // Plum Studio
    Color(0xFF8D5B2C), // Saddle Leather
    Color(0xFF37474F), // Slate Charcoal
    Color(0xFF1B6B76), // Deep Teal
  ];

  @override
  Widget build(BuildContext context) {
    if (!stows.opennoteUiMode.value || filePath == null) {
      return ColoredBox(
        color: InnerCanvas.defaultBackgroundColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: Text(
              t.home.noPreviewAvailable,
              style: TextTheme.of(context).bodyMedium?.copyWith(
                color: Stroke.defaultColor.withValues(alpha: 0.68),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final name = filePath!.substring(filePath!.lastIndexOf('/') + 1);
    final coverColor =
        _coverPalette[filePath.hashCode.abs() % _coverPalette.length];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(coverColor, Colors.white, 0.06)!,
            coverColor,
            Color.lerp(coverColor, Colors.black, 0.14)!,
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: 14,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.30),
                    Colors.black.withValues(alpha: 0.12),
                  ],
                ),
                border: Border(
                  right: BorderSide(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 18,
            width: 11,
            height: 20,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFE0A42B),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(2.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.fromLTRB(22, 18, 14, 18),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0xFFDCD6CA), width: 0.75),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C2A29),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact floating notebook preview shown while dragging a [PreviewCard].
class PreviewDragFeedback extends StatelessWidget {
  const PreviewDragFeedback({
    super.key,
    required this.filePath,
    required this.displayName,
    required this.thumbnail,
    required this.cardRadius,
  });

  final String filePath;
  final String displayName;
  final PreviewThumbnailState thumbnail;
  final double cardRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Material(
      color: Colors.transparent,
      elevation: 10,
      borderRadius: BorderRadius.circular(cardRadius),
      child: SizedBox(
        width: 142,
        height: 184,
        child: Transform.scale(
          scale: 0.92,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.45),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.26),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(cardRadius),
              child: Column(
                children: [
                  Expanded(
                    child: thumbnail.doesImageExist
                        ? Image(
                            image: thumbnail.image!,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            gaplessPlayback: true,
                          )
                        : PreviewFallbackCover(
                            filePath: filePath,
                            topRadius: cardRadius,
                          ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    color: colorScheme.surfaceContainerHigh,
                    child: Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
