/// 🤖 Generated wholely or partially with Grok 4.7
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/page_templates.dart';
import 'package:sbn/canvas_background_pattern.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(FlavorConfig.setup);

  test('a page uses the notebook paper until one is chosen', () {
    final page = EditorPage();

    expect(
      page.paperPatternOr(CanvasBackgroundPattern.dots),
      CanvasBackgroundPattern.dots,
    );
    expect(page.paperColorOr(const Color(0xFFFFFFFF)), const Color(0xFFFFFFFF));
    expect(page.paperLineHeightOr(40), 40);
    expect(page.paperLineThicknessOr(3), 3);
    expect(page.toJson(OrderedAssetCache()).containsKey('pp'), isFalse);
  });

  test('choosing a paper keeps it on that page only', () {
    final page = EditorPage();
    final legal = PageTemplate.all.firstWhere(
      (template) => template.name == 'Legal Pad (Yellow)',
    );
    legal.applyTo(page);

    expect(
      page.paperPatternOr(CanvasBackgroundPattern.dots),
      CanvasBackgroundPattern.lined,
    );
    expect(page.paperColorOr(null), PageTemplate.paperColorLegalPad);
    expect(page.paperLineHeightOr(10), legal.lineHeight);
    expect(page.paperLineThicknessOr(1), legal.lineThickness);

    final other = EditorPage();
    expect(
      other.paperPatternOr(CanvasBackgroundPattern.dots),
      CanvasBackgroundPattern.dots,
    );
    expect(other.paperColorOr(null), isNull);
  });

  test('chosen paper survives save and reload', () {
    final page = EditorPage();
    PageTemplate.all
        .firstWhere((template) => template.name == 'Cornell Notes (Cream)')
        .applyTo(page);

    final loaded = EditorPage.fromJson(
      page.toJson(OrderedAssetCache()),
      inlineAssets: const [],
      readOnly: false,
      fileVersion: EditorCoreInfo.sbnVersion,
      sbnPath: '/page_paper_test',
      assetCache: AssetCache(),
    );

    expect(
      loaded.paperPatternOr(CanvasBackgroundPattern.none),
      CanvasBackgroundPattern.cornell,
    );
    expect(loaded.paperColorOr(null), PageTemplate.paperColorWarmCream);
    expect(loaded.paperLineHeightOr(1), page.paperLineHeight);
  });
}
