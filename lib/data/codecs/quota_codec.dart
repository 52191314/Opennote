/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:saber/components/settings/nextcloud_profile.dart';
import 'package:stow_codecs/stow_codecs.dart';

/// Encodes and decodes Nextcloud storage [Quota] values for stow persistence.
class QuotaCodec extends AbstractCodec<Quota, List> {
  /// Creates a constant [QuotaCodec].
  const QuotaCodec();

  @override
  List<String> encode(Quota input) {
    return [input.used.toString(), input.total.toString()];
  }

  @override
  Quota decode(List<dynamic> encoded) {
    if (encoded.length != 2) {
      throw FormatException('Invalid quota format: $encoded');
    }
    final used = int.tryParse(encoded[0].toString()) ?? 0;
    final total = int.tryParse(encoded[1].toString()) ?? 0;
    final relative = total <= 0 ? 0.0 : used / total * 100;
    return Quota.fromJson({
      'free': total - used,
      'used': used,
      'total': total,
      'relative': relative,
      // I don't know what this [quota] field is for, but I don't use it
      'quota': total,
    });
  }
}
