/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:saber/data/sync/crdt/crdt_state_vector.dart';

/// The operation category of a CRDT mutation.
enum CrdtOpType {
  addStroke,
  deleteStroke,
  updateStroke,
  addPage,
  deletePage;
}

/// An immutable atomic operation in the CRDT document history.
class CrdtOperation implements Comparable<CrdtOperation> {
  const CrdtOperation({
    required this.replicaId,
    required this.clock,
    required this.timestamp,
    required this.type,
    required this.targetId,
    this.data = const {},
  });

  /// The unique identifier of the client/replica that originated this mutation.
  final String replicaId;

  /// The sequence clock for this replica.
  final int clock;

  /// Lamport or wall-clock timestamp in milliseconds for total ordering.
  final int timestamp;

  /// The type of operation.
  final CrdtOpType type;

  /// The target element ID (e.g. stroke UUID or page index).
  final String targetId;

  /// Arbitrary payload associated with the mutation (e.g. stroke JSON).
  final Map<String, dynamic> data;

  /// Unique operation ID composite.
  String get opId => '${replicaId}_$clock';

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
        'r': replicaId,
        'k': clock,
        't': timestamp,
        'y': type.name,
        'id': targetId,
        'd': data,
      };

  /// Deserializes an operation from JSON.
  factory CrdtOperation.fromJson(Map<String, dynamic> json) {
    final typeName = json['y'] as String? ?? 'addStroke';
    final type = CrdtOpType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => CrdtOpType.addStroke,
    );

    return CrdtOperation(
      replicaId: json['r'] as String? ?? '',
      clock: json['k'] as int? ?? 0,
      timestamp: json['t'] as int? ?? 0,
      type: type,
      targetId: json['id'] as String? ?? '',
      data: Map<String, dynamic>.from(json['d'] as Map? ?? {}),
    );
  }

  @override
  int compareTo(CrdtOperation other) {
    final timeCmp = timestamp.compareTo(other.timestamp);
    if (timeCmp != 0) return timeCmp;

    final replicaCmp = replicaId.compareTo(other.replicaId);
    if (replicaCmp != 0) return replicaCmp;

    return clock.compareTo(other.clock);
  }

  @override
  String toString() => 'CrdtOp($opId, ${type.name}, target: $targetId)';
}

/// A transport bundle containing a list of [CrdtOperation]s.
class CrdtUpdate {
  const CrdtUpdate({
    required this.operations,
    this.stateVector,
  });

  /// The discrete operations included in this update.
  final List<CrdtOperation> operations;

  /// Optional state vector summarizing the document state up to this update.
  final CrdtStateVector? stateVector;

  /// Serializes the update package to a JSON map.
  Map<String, dynamic> toJson() => {
        'ops': operations.map((e) => e.toJson()).toList(),
        if (stateVector != null) 'sv': stateVector!.toJson(),
      };

  /// Deserializes an update package from JSON.
  factory CrdtUpdate.fromJson(Map<String, dynamic> json) {
    final rawOps = json['ops'] as List? ?? [];
    final ops = rawOps
        .whereType<Map<String, dynamic>>()
        .map(CrdtOperation.fromJson)
        .toList();

    final svJson = json['sv'] as Map<String, dynamic>?;
    final sv = svJson != null ? CrdtStateVector.fromJson(svJson) : null;

    return CrdtUpdate(operations: ops, stateVector: sv);
  }

  /// Whether this update contains no operations.
  bool get isEmpty => operations.isEmpty;

  /// Whether this update contains one or more operations.
  bool get isNotEmpty => operations.isNotEmpty;
}
