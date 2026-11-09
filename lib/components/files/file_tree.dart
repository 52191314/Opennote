/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/i18n/strings.g.dart';

class FileTree extends StatelessWidget {
  const FileTree({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);

    return Padding(
      padding: const .symmetric(
        horizontal: OpennoteTokens.s3,
        vertical: OpennoteTokens.s2,
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          DragTarget<String>(
            onWillAcceptWithDetails: (details) {
              final data = details.data;
              final slashIndex = data.lastIndexOf('/');
              return slashIndex > 0; // Not already in root
            },
            onAcceptWithDetails: (details) async {
              final sourcePath = details.data;
              final itemName = sourcePath.substring(
                sourcePath.lastIndexOf('/') + 1,
              );
              await FileManager.moveItem(sourcePath, '/');
              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Moved $itemName to root'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, candidateData, rejectedData) {
              final isHovered = candidateData.isNotEmpty;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(OpennoteTokens.radiusSm),
                  color: isHovered
                      ? colorScheme.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  border: isHovered
                      ? Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.6),
                        )
                      : null,
                ),
                padding: const .symmetric(
                  horizontal: OpennoteTokens.s2,
                  vertical: OpennoteTokens.s1,
                ),
                child: Row(
                  children: [
                    Text(
                      t.home.tabs.browse.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: .w700,
                        letterSpacing: 0.8,
                        color: isHovered
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.75,
                              ),
                      ),
                    ),
                    if (isHovered) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.drive_file_move_outline,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: OpennoteTokens.s1),
          const Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: FileTreeBranch(path: null, isDirectory: true),
            ),
          ),
        ],
      ),
    );
  }
}

class FileTreeBranch extends StatefulWidget {
  const FileTreeBranch({
    super.key,
    required this.path,
    required this.isDirectory,
  });

  final String? path;
  final bool isDirectory;

  @override
  State<FileTreeBranch> createState() => _FileTreeBranchState();
}

class _FileTreeBranchState extends State<FileTreeBranch> {
  DirectoryChildren? children;
  var areChildrenVisible = false;

  StreamSubscription? fileWriteSubscription;

  @override
  void initState() {
    _getInfo();
    fileWriteSubscription = FileManager.fileWriteStream.stream.listen(_getInfo);
    super.initState();
  }

  void _getInfo([FileOperation? _]) async {
    if (!mounted) return;
    if (widget.isDirectory) {
      try {
        children = await FileManager.getChildrenOfDirectory(widget.path ?? '/');
      } catch (e) {
        children = null;
      }
    }
    areChildrenVisible = children != null && children!.onlyOneChild();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);
    final rowRadius = BorderRadius.circular(OpennoteTokens.radiusSm);

    final isDesktop = switch (Theme.of(context).platform) {
      TargetPlatform.windows ||
      TargetPlatform.macOS ||
      TargetPlatform.linux => true,
      _ => false,
    };

    final nodeRow = widget.path == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const .symmetric(vertical: 1.5),
            child: Material(
              color: Colors.transparent,
              borderRadius: rowRadius,
              child: InkWell(
                borderRadius: rowRadius,
                hoverColor: colorScheme.primary.withValues(alpha: 0.06),
                splashColor: colorScheme.primary.withValues(alpha: 0.10),
                onTap: () {
                  setState(() {
                    if (widget.isDirectory) {
                      areChildrenVisible = !areChildrenVisible;
                    } else {
                      context.push(RoutePaths.editFilePath(widget.path ?? '/'));
                    }
                  });
                },
                child: Padding(
                  padding: const .symmetric(
                    horizontal: OpennoteTokens.s2,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      if (widget.isDirectory) ...[
                        Icon(
                          areChildrenVisible
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_right_rounded,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          areChildrenVisible
                              ? Icons.folder_open_rounded
                              : Icons.folder_rounded,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                      ] else ...[
                        const SizedBox(width: 18),
                        Icon(
                          Icons.description_outlined,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                      const SizedBox(width: OpennoteTokens.s2),
                      Expanded(
                        child: Text(
                          widget.path!.substring(
                            widget.path!.lastIndexOf('/') + 1,
                          ),
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 13.5,
                            fontWeight: widget.isDirectory ? .w600 : .w400,
                            color: colorScheme.onSurface,
                          ),
                          overflow: .ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

    final feedbackWidget = widget.path == null
        ? const SizedBox.shrink()
        : Material(
            elevation: 4,
            borderRadius: rowRadius,
            color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.95),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isDirectory
                        ? Icons.folder_rounded
                        : Icons.description_outlined,
                    size: 16,
                    color: widget.isDirectory
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.path!.substring(widget.path!.lastIndexOf('/') + 1),
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );

    final draggableNode = widget.path == null
        ? const SizedBox.shrink()
        : isDesktop
        ? Draggable<String>(
            data: widget.path!,
            feedback: feedbackWidget,
            childWhenDragging: Opacity(opacity: 0.4, child: nodeRow),
            child: nodeRow,
          )
        : LongPressDraggable<String>(
            delay: const Duration(milliseconds: 200),
            data: widget.path!,
            feedback: feedbackWidget,
            childWhenDragging: Opacity(opacity: 0.4, child: nodeRow),
            child: nodeRow,
          );

    Widget nodeWidget = draggableNode;

    if (widget.path != null && widget.isDirectory) {
      nodeWidget = DragTarget<String>(
        onWillAcceptWithDetails: (details) {
          final data = details.data;
          final targetFolderPath = widget.path!;
          if (data == targetFolderPath) return false;
          if (targetFolderPath.startsWith('$data/')) return false;
          final dataParent = data.substring(0, data.lastIndexOf('/'));
          final normalizedParent = dataParent.isEmpty ? '/' : dataParent;
          if (targetFolderPath == normalizedParent) return false;
          return true;
        },
        onAcceptWithDetails: (details) async {
          final data = details.data;
          final targetFolderPath = widget.path!;
          final itemName = data.substring(data.lastIndexOf('/') + 1);
          final folderName = targetFolderPath.substring(
            targetFolderPath.lastIndexOf('/') + 1,
          );

          await FileManager.moveItem(data, targetFolderPath);

          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Moved $itemName to $folderName'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isTargeted = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: rowRadius,
              color: isTargeted
                  ? colorScheme.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              border: isTargeted
                  ? Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.6),
                      width: 1.2,
                    )
                  : null,
            ),
            child: draggableNode,
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: .start,
      children: [
        if (widget.path != null) nodeWidget,
        if ((widget.path == null || areChildrenVisible) && children != null)
          Padding(
            padding: (widget.path != null) ? const .only(left: 14) : .zero,
            child: DecoratedBox(
              decoration: widget.path != null
                  ? BoxDecoration(
                      border: BorderDirectional(
                        start: BorderSide(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.35,
                          ),
                          width: 1,
                        ),
                      ),
                    )
                  : const BoxDecoration(),
              child: Padding(
                padding: (widget.path != null) ? const .only(left: 6) : .zero,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    for (var i = 0; i < children!.directories.length; i++)
                      FileTreeBranch(
                        path:
                            '${widget.path ?? ''}/${children!.directories[i]}',
                        isDirectory: true,
                      ),
                    for (var i = 0; i < children!.files.length; i++)
                      FileTreeBranch(
                        path: '${widget.path ?? ''}/${children!.files[i]}',
                        isDirectory: false,
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    fileWriteSubscription?.cancel();
    super.dispose();
  }
}
