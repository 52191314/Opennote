/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

/// Represents a vector clock mapping replica/client IDs to their latest
/// continuous sequence numbers, matching the Yjs State Vector design.
class CrdtStateVector {
  CrdtStateVector([Map<String, int>? initialClocks])
      : clocks = Map<String, int>.from(initialClocks ?? const {});

  /// Clocks indexed by client/replica ID.
  final Map<String, int> clocks;

  /// Gets the clock for a given [replicaId], defaulting to 0.
  int getClock(String replicaId) => clocks[replicaId] ?? 0;

  /// Sets or advances the clock for [replicaId] to at least [clock].
  void setClock(String replicaId, int clock) {
    final current = getClock(replicaId);
    if (clock > current) {
      clocks[replicaId] = clock;
    }
  }

  /// Increments the clock for [replicaId] and returns the new value.
  int increment(String replicaId) {
    final next = getClock(replicaId) + 1;
    clocks[replicaId] = next;
    return next;
  }

  /// Returns true if this state vector has already observed the given
  /// [clock] from [replicaId].
  bool hasSeen(String replicaId, int clock) {
    return getClock(replicaId) >= clock;
  }

  /// Merges another [other] vector into this one taking the maximum clock
  /// for each replica.
  void merge(CrdtStateVector other) {
    for (final entry in other.clocks.entries) {
      setClock(entry.key, entry.value);
    }
  }

  /// Clones this state vector.
  CrdtStateVector copy() => CrdtStateVector(clocks);

  /// Serializes this state vector to a JSON-compatible map.
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(clocks);

  /// Deserializes a state vector from a JSON map.
  factory CrdtStateVector.fromJson(Map<String, dynamic> json) {
    final map = <String, int>{};
    for (final entry in json.entries) {
      if (entry.value is int) {
        map[entry.key] = entry.value as int;
      }
    }
    return CrdtStateVector(map);
  }

  @override
  String toString() => 'CrdtStateVector($clocks)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrdtStateVector &&
          clocks.length == other.clocks.length &&
          clocks.entries.every((e) => other.clocks[e.key] == e.value);

  @override
  int get hashCode => clocks.hashCode;
}
