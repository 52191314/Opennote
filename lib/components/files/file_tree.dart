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
          Padding(
            padding: const .symmetric(
              horizontal: OpennoteTokens.s2,
              vertical: OpennoteTokens.s1,
            ),
            child: Text(
              t.home.tabs.browse.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                fontWeight: .w700,
                letterSpacing: 0.8,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
              ),
            ),
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
    if (widget.isDirectory)
      children = await FileManager.getChildrenOfDirectory(widget.path ?? '/');
    areChildrenVisible = children != null && children!.onlyOneChild();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);
    final rowRadius = BorderRadius.circular(OpennoteTokens.radiusSm);

    return Column(
      crossAxisAlignment: .start,
      children: [
        if (widget.path != null)
          Padding(
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
          ),
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
