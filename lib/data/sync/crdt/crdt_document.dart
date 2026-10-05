/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/sync/crdt/crdt_operation.dart';
import 'package:saber/data/sync/crdt/crdt_state_vector.dart';
import 'package:sbn/has_size.dart';

/// A conflict-free replicated document container for note documents.
///
/// Implements deterministic CRDT synchronization modeled after Yjs.
/// Tracks atomic operations, maintains state vectors, handles tombstones,
/// and computes delta updates for real-time collaboration.
class CrdtDocument {
  CrdtDocument({required this.replicaId}) : stateVector = CrdtStateVector();

  /// Unique identifier of this client / replica.
  final String replicaId;

  /// Vector clock of all seen operations across all replicas.
  final CrdtStateVector stateVector;

  /// The chronological journal of all observed CRDT operations.
  final List<CrdtOperation> _log = [];

  /// Active stroke records mapped by stroke ID.
  final Map<String, Map<String, dynamic>> _activeStrokes = {};

  /// Page mapping for each active stroke ID.
  final Map<String, int> _strokePages = {};

  /// Set of deleted stroke IDs (tombstones).
  final Set<String> _tombstones = {};

  /// The list of recorded operations.
  List<CrdtOperation> get operations => List.unmodifiable(_log);

  /// Active stroke IDs.
  Iterable<String> get activeStrokeIds => _activeStrokes.keys;

  /// Total count of active strokes.
  int get strokeCount => _activeStrokes.length;

  /// Records the insertion of a new stroke into page [pageIndex].
  CrdtOperation addStroke({
    required String strokeId,
    required int pageIndex,
    required Map<String, dynamic> strokeJson,
    int? customTimestamp,
  }) {
    final clock = stateVector.increment(replicaId);
    final op = CrdtOperation(
      replicaId: replicaId,
      clock: clock,
      timestamp: customTimestamp ?? DateTime.now().millisecondsSinceEpoch,
      type: CrdtOpType.addStroke,
      targetId: strokeId,
      data: {'page': pageIndex, 'stroke': strokeJson},
    );

    _log.add(op);
    if (!_tombstones.contains(strokeId)) {
      _activeStrokes[strokeId] = Map<String, dynamic>.from(strokeJson);
      _strokePages[strokeId] = pageIndex;
    }
    return op;
  }

  /// Records the deletion / erasure of an existing stroke.
  CrdtOperation deleteStroke(String strokeId, {int? customTimestamp}) {
    final clock = stateVector.increment(replicaId);
    final op = CrdtOperation(
      replicaId: replicaId,
      clock: clock,
      timestamp: customTimestamp ?? DateTime.now().millisecondsSinceEpoch,
      type: CrdtOpType.deleteStroke,
      targetId: strokeId,
    );

    _log.add(op);
    _tombstones.add(strokeId);
    _activeStrokes.remove(strokeId);
    _strokePages.remove(strokeId);
    return op;
  }

  /// Records an in-place mutation of a stroke (e.g. tape reveal/conceal toggle).
  CrdtOperation updateStroke({
    required String strokeId,
    required Map<String, dynamic> patch,
    int? customTimestamp,
  }) {
    final clock = stateVector.increment(replicaId);
    final op = CrdtOperation(
      replicaId: replicaId,
      clock: clock,
      timestamp: customTimestamp ?? DateTime.now().millisecondsSinceEpoch,
      type: CrdtOpType.updateStroke,
      targetId: strokeId,
      data: {'patch': patch},
    );

    _log.add(op);
    if (!_tombstones.contains(strokeId) &&
        _activeStrokes.containsKey(strokeId)) {
      _activeStrokes[strokeId]!.addAll(patch);
    }
    return op;
  }

  /// Computes a delta update containing all operations missing from [remoteVector].
  /// Matches Yjs `encodeStateAsUpdate(remoteStateVector)`.
  CrdtUpdate encodeDelta(CrdtStateVector remoteVector) {
    final missingOps = <CrdtOperation>[];
    for (final op in _log) {
      if (!remoteVector.hasSeen(op.replicaId, op.clock)) {
        missingOps.add(op);
      }
    }
    return CrdtUpdate(operations: missingOps, stateVector: stateVector.copy());
  }

  /// Applies a [CrdtUpdate] payload received from a remote replica.
  /// Integrates operations idempotently, respecting tombstones and vector clocks.
  void applyUpdate(CrdtUpdate update) {
    for (final op in update.operations) {
      if (stateVector.hasSeen(op.replicaId, op.clock)) {
        continue;
      }

      stateVector.setClock(op.replicaId, op.clock);
      _log.add(op);

      switch (op.type) {
        case CrdtOpType.addStroke:
          if (!_tombstones.contains(op.targetId)) {
            final strokeData = op.data['stroke'] as Map?;
            if (strokeData != null) {
              _activeStrokes[op.targetId] = Map<String, dynamic>.from(
                strokeData,
              );
              _strokePages[op.targetId] = op.data['page'] as int? ?? 0;
            }
          }
        case CrdtOpType.deleteStroke:
          _tombstones.add(op.targetId);
          _activeStrokes.remove(op.targetId);
          _strokePages.remove(op.targetId);
        case CrdtOpType.updateStroke:
          if (!_tombstones.contains(op.targetId) &&
              _activeStrokes.containsKey(op.targetId)) {
            final patch = op.data['patch'] as Map?;
            if (patch != null) {
              _activeStrokes[op.targetId]!.addAll(
                Map<String, dynamic>.from(patch),
              );
            }
          }
        case CrdtOpType.addPage:
        case CrdtOpType.deletePage:
          break;
      }
    }
  }

  /// Bidirectionally synchronizes two in-memory document replicas.
  void syncWith(CrdtDocument other) {
    final deltaForOther = encodeDelta(other.stateVector);
    final deltaForSelf = other.encodeDelta(stateVector);

    other.applyUpdate(deltaForOther);
    applyUpdate(deltaForSelf);
  }

  /// Reconstructs the active [Stroke]s belonging to [pageIndex].
  List<Stroke> reconstructPageStrokes(
    int pageIndex,
    HasSize page, {
    int fileVersion = 19,
  }) {
    final strokes = <Stroke>[];
    for (final entry in _activeStrokes.entries) {
      final id = entry.key;
      final strokePageIndex = _strokePages[id];
      if (strokePageIndex == pageIndex) {
        try {
          final stroke = Stroke.fromJson(
            entry.value,
            fileVersion: fileVersion,
            pageIndex: pageIndex,
            page: page,
          );
          strokes.add(stroke);
        } catch (_) {
          // Skip corrupt or unparseable stroke data
        }
      }
    }
    return strokes;
  }
}
