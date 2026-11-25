/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:stow/stow.dart';
import 'package:stow_codecs/stow_codecs.dart';

/// Tracks whether the current Dart isolate is the main UI isolate.
///
/// When `false`, all [Stow] instances are created in volatile mode so
/// background isolates and unit tests stay in-memory.
abstract final class StowIsolate {
  static var _isOnMainIsolate = false;

  /// Whether newly constructed stows should run in volatile mode.
  static bool get isVolatile => !_isOnMainIsolate;

  /// Marks the current isolate as the main UI isolate.
  static void markAsOnMainIsolate() {
    _isOnMainIsolate = true;
  }
}

/// A [Stow] that transforms the value of another [Stow].
class TransformedStow<T_in, T_out> extends Stow<dynamic, T_out, dynamic> {
  /// The underlying source stow.
  final Stow<dynamic, T_in, dynamic> parent;

  /// Converts a value from [parent] to [T_out].
  final T_out Function(T_in) transform;

  /// Converts a [T_out] value back to [T_in] for [parent].
  final T_in Function(T_out) reverseTransform;

  @override
  T_out get value => transform(parent.value);

  @override
  set value(T_out value) => parent.value = reverseTransform(value);

  /// Creates a [TransformedStow] backed by [parent].
  TransformedStow(this.parent, this.transform, this.reverseTransform)
    : super(parent.key, transform(parent.defaultValue), volatile: true) {
    parent.addListener(notifyListeners);
  }

  @override
  Future<dynamic> protectedRead() async => null;

  @override
  Future<void> protectedWrite(dynamic value) async {}

  @override
  String toString() {
    return 'TransformedPref<$T_in, $T_out>(from ${parent.key}, $value)';
  }

  @override
  void dispose() {
    parent.removeListener(notifyListeners);
    super.dispose();
  }
}

/// Encodes and decodes a `List<int>` as a comma-separated string.
class IntListCsvCodec extends AbstractCodec<List<int>, String> {
  /// Creates a constant [IntListCsvCodec].
  const IntListCsvCodec();

  @override
  String encode(List<int> input) => input.join(',');

  @override
  List<int> decode(String encoded) =>
      encoded.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();
}

/// Encodes and decodes a `List<double>` as a comma-separated string.
class DoubleListCsvCodec extends AbstractCodec<List<double>, String> {
  /// Creates a constant [DoubleListCsvCodec].
  const DoubleListCsvCodec();

  @override
  String encode(List<double> input) => input.join(',');

  @override
  List<double> decode(String encoded) =>
      encoded.split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).toList();
}
