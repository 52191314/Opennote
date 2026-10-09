/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:golden_screenshot/src/apple_fonts.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  print('Robust Apple Fonts Downloader');
  if (AppleFonts.allOtfFiles.isNotEmpty) {
    print('Apple fonts already present at ${AppleFonts.fontsDirectory.path}');
    return;
  }

  final tmpDir = Directory.systemTemp.createTempSync('apple_fonts_download');
  try {
    final dmgFile = File(p.join(tmpDir.path, 'SF-Pro.dmg'));
    const url =
        'https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg';
    print('Downloading Apple fonts from $url ...');
    final client = HttpClient()
      ..findProxy = HttpClient.findProxyFromEnvironment;
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('Download failed with status ${response.statusCode}');
    }
    await dmgFile.create(recursive: true);
    await response.pipe(dmgFile.openWrite());
    print('Downloaded ${dmgFile.path} (${await dmgFile.length()} bytes)');

    final sevenZip = await _find7z() ?? '7z';

    // Step 1: Extract DMG
    final extractedDmg = Directory(p.join(tmpDir.path, 'extracted_dmg'));
    await extractedDmg.create(recursive: true);
    final res = await Process.run(sevenZip, [
      'x',
      dmgFile.path,
      '-o${extractedDmg.path}',
      '-y',
    ]);
    if (res.exitCode != 0) {
      print('Warning: DMG extraction output: ${res.stdout}\n${res.stderr}');
    }

    // Step 2: Locate all .pkg files recursively
    final pkgFiles = extractedDmg
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.pkg'))
        .toList();

    if (pkgFiles.isEmpty) {
      throw StateError(
        'No .pkg files found in extracted DMG at ${extractedDmg.path}',
      );
    }

    final extractedPkg = Directory(p.join(tmpDir.path, 'extracted_pkg'));
    await extractedPkg.create(recursive: true);

    for (final pkg in pkgFiles) {
      print('Extracting package: ${pkg.path}');
      await Process.run(sevenZip, [
        'x',
        pkg.path,
        '-o${extractedPkg.path}',
        '-y',
      ]);
    }

    // Step 3: Locate any Payload files or archives
    final payloadFiles = extractedPkg
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => p.basename(f.path).startsWith('Payload'))
        .toList();

    final extractedPayload = Directory(
      p.join(tmpDir.path, 'extracted_payload'),
    );
    await extractedPayload.create(recursive: true);

    for (final payload in payloadFiles) {
      print('Extracting payload: ${payload.path}');
      await Process.run(sevenZip, [
        'x',
        payload.path,
        '-o${extractedPayload.path}',
        '-y',
      ]);
    }

    // In case Payload extracted another Payload~ or cpio archive, extract those too
    final cpioFiles = extractedPayload
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (f) =>
              p.basename(f.path).startsWith('Payload~') ||
              f.path.endsWith('.cpio'),
        )
        .toList();

    for (final cpio in cpioFiles) {
      print('Extracting cpio archive: ${cpio.path}');
      await Process.run(sevenZip, [
        'x',
        cpio.path,
        '-o${extractedPayload.path}',
        '-y',
      ]);
    }

    // Step 4: Scan tmpDir recursively for all .otf files and copy to fontsDirectory
    await AppleFonts.fontsDirectory.create(recursive: true);
    final allOtf = tmpDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => p.extension(f.path).toLowerCase() == '.otf')
        .toList();

    print('Discovered ${allOtf.length} .otf font files');
    for (final otf in allOtf) {
      final dest = File(
        p.join(AppleFonts.fontsDirectory.path, p.basename(otf.path)),
      );
      await otf.copy(dest.path);
    }

    print(
      'Successfully copied ${allOtf.length} fonts to ${AppleFonts.fontsDirectory.path}',
    );
  } finally {
    if (tmpDir.existsSync()) {
      await tmpDir.delete(recursive: true).catchError((_) => tmpDir);
    }
  }
}

Future<String?> _find7z() async {
  for (final cmd in ['7z', '7zz', '7za']) {
    try {
      final res = await Process.run(cmd, ['--help']);
      if (res.exitCode == 0) return cmd;
    } catch (_) {}
  }
  return null;
}
