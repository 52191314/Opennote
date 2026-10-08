/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';

const _offset = Offset(40, -25.5);
const _rotation = 0.75;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(FlavorConfig.setup);

  group('Moved and rotated page text', () {
    test('survives saving and reloading the page', () {
      final page = EditorPage(
        textContentOffset: _offset,
        textContentRotation: _rotation,
      );

      final reloaded = _reload(page);

      expect(reloaded.textContentOffset, _offset);
      expect(reloaded.textContentRotation, _rotation);
    });

    test('is not written for pages whose text was never moved', () {
      final json = EditorPage().toJson(OrderedAssetCache());

      expect(json.containsKey('to'), isFalse);
      expect(json.containsKey('tr'), isFalse);
    });

    test('defaults to unmoved when the file has no text transform', () {
      final reloaded = _reload(EditorPage());

      expect(reloaded.textContentOffset, Offset.zero);
      expect(reloaded.textContentRotation, 0);
    });

    test('is kept by copyWith', () {
      final page = EditorPage(
        textContentOffset: _offset,
        textContentRotation: _rotation,
      );

      final copy = page.copyWith(bookmarked: true);

      expect(copy.textContentOffset, _offset);
      expect(copy.textContentRotation, _rotation);
    });

    test('is kept when the page is cloned for export', () {
      final page = EditorPage(
        textContentOffset: _offset,
        textContentRotation: _rotation,
      );

      final clone = page.cloneForRasterization();
      addTearDown(clone.disposeClonedData);

      expect(clone.textContentOffset, _offset);
      expect(clone.textContentRotation, _rotation);
    });
  });
}

EditorPage _reload(EditorPage page) => EditorPage.fromJson(
  page.toJson(OrderedAssetCache()),
  inlineAssets: const [],
  readOnly: false,
  fileVersion: EditorCoreInfo.sbnVersion,
  sbnPath: '/page_text_transform_test',
  assetCache: AssetCache(),
);
