/// 🤖 Generated with DeepSeek v4 Flash
library;

import 'package:flutter/material.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/i18n/strings.g.dart';

/// A dialog for managing layers (add, remove, reorder, toggle visibility).
class LayerManager extends StatefulWidget {
  final EditorPage page;
  final VoidCallback onChanged;

  const LayerManager({
    super.key,
    required this.page,
    required this.onChanged,
  });

  @override
  State<LayerManager> createState() => _LayerManagerState();
}

class _LayerManagerState extends State<LayerManager> {
  late List<Layer> _layers;
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _layers = widget.page.layers;
    _activeIndex = widget.page.activeLayerIndex;
  }

  void _setState() {
    widget.page.activeLayerIndex = _activeIndex;
    setState(() {});
    widget.onChanged();
  }

  void _addLayer() {
    setState(() {
      _layers.add(Layer(name: 'Layer ${_layers.length + 1}'));
    });
    _setState();
  }

  void _removeLayer(int index) {
    if (_layers.length <= 1) return;
    setState(() {
      _layers.removeAt(index);
      if (_activeIndex >= _layers.length) {
        _activeIndex = _layers.length - 1;
      }
    });
    _setState();
  }

  void _moveLayer(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final layer = _layers.removeAt(oldIndex);
      _layers.insert(newIndex, layer);
      if (_activeIndex == oldIndex) {
        _activeIndex = newIndex;
      } else if (_activeIndex > oldIndex && _activeIndex <= newIndex) {
        _activeIndex--;
      } else if (_activeIndex < oldIndex && _activeIndex >= newIndex) {
        _activeIndex++;
      }
    });
    _setState();
  }

  void _mergeDown(int index) {
    if (index <= 0) return;
    final upper = _layers[index];
    final lower = _layers[index - 1];
    lower.strokes.addAll(upper.strokes);
    _removeLayer(index);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.layers, size: 24),
          const SizedBox(width: 8),
          Text('Layers'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Layer',
            onPressed: _addLayer,
          ),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: _layers.isEmpty
            ? const Center(child: Text('No layers'))
            : ReorderableListView.builder(
              shrinkWrap: true,
              itemCount: _layers.length,
              onReorder: _moveLayer,
              itemBuilder: (context, index) {
                final layer = _layers[index];
                final isActive = index == _activeIndex;
                return Container(
                  key: ValueKey('layer_$index'),
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest?.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: isActive
                        ? Border.all(color: colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: ListTile(
                    dense: true,
                    leading: IconButton(
                      icon: Icon(
                        layer.visible ? Icons.visibility : Icons.visibility_off,
                        size: 20,
                      ),
                      onPressed: () {
                        layer.visible = !layer.visible;
                        _setState();
                      },
                    ),
                    title: Text(
                      layer.name,
                      style: TextStyle(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text('${layer.strokes.length} strokes'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (index > 0)
                          IconButton(
                            icon: const Icon(Icons.merge_type, size: 18),
                            tooltip: 'Merge Down',
                            onPressed: () => _mergeDown(index),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          tooltip: 'Delete Layer',
                          onPressed: _layers.length > 1
                              ? () => _removeLayer(index)
                              : null,
                        ),
                      ],
                    ),
                    onTap: () {
                      _activeIndex = index;
                      _setState();
                    },
                  ),
                );
              },
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}
