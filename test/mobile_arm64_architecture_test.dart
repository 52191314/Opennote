/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

String _readNormalized(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: '$path must exist');
  return file.readAsStringSync().replaceAll('\r\n', '\n');
}

String _stripSlashComments(String source) {
  return source
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .replaceAll(RegExp(r'//.*'), '');
}

String _stripHashComments(String source) {
  return source
      .split('\n')
      .where((line) => !line.trimLeft().startsWith('#'))
      .join('\n');
}

String _stripXmlComments(String source) {
  return source.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');
}

void main() {
  group('1. Non-Mobile Directories & Legacy Build Artifacts Removal', () {
    test('removes all desktop, web, and Linux packaging directories', () {
      const removedDirectories = [
        'linux',
        'macos',
        'windows',
        'web',
        'flatpak',
        'snap',
        'installers',
      ];

      for (final dirPath in removedDirectories) {
        expect(
          Directory(dirPath).existsSync(),
          isFalse,
          reason: 'Non-mobile directory "$dirPath" must be removed',
        );
      }
    });

    test('removes legacy Rust and desktop patch/icon artifacts', () {
      const removedFiles = [
        'rust-toolchain.toml',
        'patches/post/patch_rust_versions.sh',
        'patches/pre/windows_stylus_buttons.patch',
        'patches/pre/windows_stylus_buttons.sh',
        'patches/pre/remove_linux_dependencies.sh',
        'assets/icon/icon_macos.png',
      ];

      for (final filePath in removedFiles) {
        expect(
          File(filePath).existsSync(),
          isFalse,
          reason: 'Legacy build artifact "$filePath" must be removed',
        );
      }
    });
  });

  group('2. Slimmed Mobile Dependencies (pubspec.yaml)', () {
    late YamlMap pubspec;

    setUpAll(() {
      final content = _readNormalized('pubspec.yaml');
      final parsed = loadYaml(content);
      expect(parsed, isA<YamlMap>());
      pubspec = parsed as YamlMap;
    });

    test('excludes bloated Rust/native and desktop-only packages', () {
      const forbiddenPackages = [
        'super_clipboard',
        'fast_image_resizer',
        'regexed_validator',
        'keybinder',
        'window_manager',
        'yaru',
      ];

      final dependencies = pubspec['dependencies'] as YamlMap?;
      final devDependencies = pubspec['dev_dependencies'] as YamlMap?;
      final dependencyOverrides = pubspec['dependency_overrides'] as YamlMap?;

      expect(dependencies, isNotNull);

      for (final pkg in forbiddenPackages) {
        expect(
          dependencies!.containsKey(pkg),
          isFalse,
          reason: 'dependencies must not include "$pkg"',
        );
        if (devDependencies != null) {
          expect(
            devDependencies.containsKey(pkg),
            isFalse,
            reason: 'dev_dependencies must not include "$pkg"',
          );
        }
        if (dependencyOverrides != null) {
          expect(
            dependencyOverrides.containsKey(pkg),
            isFalse,
            reason: 'dependency_overrides must not include "$pkg"',
          );
        }
      }
    });
  });

  group('3. Android ARM64 & Size Optimization Configuration', () {
    test(
      'android/app/build.gradle.kts enforces arm64-v8a, R8 shrinking, '
      'legacy JNI packaging, localeFilters, and no Material Components bloat',
      () {
        final rawGradle = _readNormalized('android/app/build.gradle.kts');
        final activeGradle = _stripSlashComments(rawGradle);

        expect(
          activeGradle,
          contains('abiFilters'),
          reason: 'build.gradle.kts must configure ndk abiFilters',
        );
        expect(
          activeGradle,
          contains('arm64-v8a'),
          reason: 'build.gradle.kts must target arm64-v8a',
        );
        expect(
          activeGradle,
          isNot(contains('armeabi-v7a')),
          reason: 'build.gradle.kts must exclude 32-bit armeabi-v7a',
        );
        expect(
          activeGradle,
          isNot(contains('x86_64')),
          reason: 'build.gradle.kts must exclude emulator x86_64 ABI',
        );
        expect(
          activeGradle,
          matches(RegExp(r'isMinifyEnabled\s*=\s*true')),
          reason: 'Release build must enable R8 code minification',
        );
        expect(
          activeGradle,
          matches(RegExp(r'isShrinkResources\s*=\s*true')),
          reason: 'Release build must enable resource shrinking',
        );
        expect(
          activeGradle,
          matches(RegExp(r'useLegacyPackaging\s*=\s*true')),
          reason: 'JNI libs must use compressed legacy APK packaging',
        );
        expect(
          activeGradle,
          contains('localeFilters'),
          reason: 'androidResources must restrict packaged locales',
        );
        expect(
          activeGradle,
          isNot(contains('com.google.android.material:material')),
          reason: 'Unused Android Material Components library must be removed',
        );
      },
    );

    test(
      'AndroidManifest.xml enables Impeller and removes SuperClipboard provider',
      () {
        final rawManifest = _readNormalized(
          'android/app/src/main/AndroidManifest.xml',
        );
        final activeManifest = _stripXmlComments(rawManifest);

        expect(
          activeManifest,
          contains('io.flutter.embedding.android.EnableImpeller'),
          reason: 'AndroidManifest.xml must explicitly enable Impeller',
        );
        expect(
          activeManifest,
          matches(
            RegExp(
              r'<meta-data[^>]*io\.flutter\.embedding\.android\.EnableImpeller[^>]*android:value="true"|'
              r'<meta-data[^>]*android:value="true"[^>]*io\.flutter\.embedding\.android\.EnableImpeller',
            ),
          ),
          reason: 'EnableImpeller meta-data must be set to true',
        );
        expect(
          activeManifest,
          isNot(contains('SuperClipboardDataProvider')),
          reason: 'SuperClipboardDataProvider must be removed from manifest',
        );
        expect(
          activeManifest,
          isNot(contains('com.superlist.super_native_extensions')),
          reason: 'super_native_extensions provider must be removed',
        );
      },
    );
  });

  group('4. iOS ARM64, LTO/Size Flags & 120Hz Impeller Configuration', () {
    test('ios/Flutter/Release.xcconfig enforces arm64, -Osize, Oz, ThinLTO, '
        'and dead-code stripping', () {
      final rawXcconfig = _readNormalized('ios/Flutter/Release.xcconfig');
      final activeXcconfig = _stripSlashComments(rawXcconfig);

      expect(
        activeXcconfig,
        contains('arm64'),
        reason: 'Release.xcconfig must enforce arm64 architecture',
      );
      expect(
        activeXcconfig,
        contains('-Osize'),
        reason: 'Release.xcconfig must enforce Swift -Osize optimization',
      );
      expect(
        activeXcconfig,
        matches(RegExp(r'GCC_OPTIMIZATION_LEVEL\s*=\s*z\b')),
        reason:
            'Release.xcconfig must enforce Clang -Oz (GCC_OPTIMIZATION_LEVEL = z)',
      );
      expect(
        activeXcconfig,
        matches(RegExp(r'LLVM_LTO\s*=\s*YES_THIN')),
        reason: 'Release.xcconfig must enable LLVM_LTO = YES_THIN',
      );
      expect(
        activeXcconfig,
        matches(RegExp(r'DEAD_CODE_STRIPPING\s*=\s*YES')),
        reason: 'Release.xcconfig must enable DEAD_CODE_STRIPPING = YES',
      );
    });

    test(
      'ios/Podfile enforces arm64, -Osize, Oz, ThinLTO, and dead-code stripping',
      () {
        final rawPodfile = _readNormalized('ios/Podfile');
        final activePodfile = _stripHashComments(rawPodfile);

        expect(
          activePodfile,
          contains('arm64'),
          reason: 'Podfile must enforce arm64 target architecture',
        );
        expect(
          activePodfile,
          contains('-Osize'),
          reason: 'Podfile must enforce Swift -Osize optimization',
        );
        expect(
          activePodfile,
          matches(RegExp(r'(?:Oz|GCC_OPTIMIZATION_LEVEL[^\n]*\bz\b)')),
          reason: 'Podfile must enforce Clang Oz size optimization',
        );
        expect(
          activePodfile,
          contains('LLVM_LTO'),
          reason: 'Podfile must configure LLVM_LTO',
        );
        expect(
          activePodfile,
          contains('YES_THIN'),
          reason: 'Podfile must set LLVM_LTO to YES_THIN',
        );
        expect(
          activePodfile,
          contains('DEAD_CODE_STRIPPING'),
          reason: 'Podfile must enable DEAD_CODE_STRIPPING',
        );
      },
    );

    test(
      'ios/Runner/Info.plist enables ProMotion 120Hz and Impeller rendering',
      () {
        final infoPlist = _stripXmlComments(
          _readNormalized('ios/Runner/Info.plist'),
        );

        expect(
          infoPlist,
          matches(
            RegExp(
              r'<key>CADisableMinimumFrameDurationOnPhone</key>\s*<true/>',
            ),
          ),
          reason: 'Info.plist must enable CADisableMinimumFrameDurationOnPhone',
        );
        expect(
          infoPlist,
          matches(RegExp(r'<key>FLTEnableImpeller</key>\s*<true/>')),
          reason: 'Info.plist must explicitly enable FLTEnableImpeller',
        );
      },
    );
  });

  group('5. CI Workflows & Native Scripts ARM64-Only Enforcement', () {
    test(
      '.github/workflows/android.yml targets android-arm64 without 32-bit/x86_64 '
      'or Rust targets',
      () {
        final rawWorkflow = _readNormalized('.github/workflows/android.yml');
        final activeWorkflow = _stripHashComments(rawWorkflow);

        expect(
          activeWorkflow,
          contains('android-arm64'),
          reason: 'Android workflow must target android-arm64 explicitly',
        );
        expect(
          activeWorkflow,
          isNot(contains('armv7-linux-androideabi')),
          reason: 'Android workflow must not build 32-bit Rust target',
        );
        expect(
          activeWorkflow,
          isNot(contains('x86_64-linux-android')),
          reason: 'Android workflow must not build x86_64 Rust target',
        );
        expect(
          activeWorkflow,
          isNot(contains('patch_rust_versions.sh')),
          reason: 'Android workflow must not invoke removed Rust patch script',
        );
        expect(
          activeWorkflow,
          isNot(contains('remove_linux_dependencies.sh')),
          reason: 'Android workflow must not invoke removed Linux patch script',
        );
      },
    );

    test('scripts/build_pdfium.sh targets arm64 only', () {
      final rawScript = _readNormalized('scripts/build_pdfium.sh');
      final activeScript = _stripHashComments(rawScript);

      expect(
        activeScript,
        contains('PDFium_TARGET_CPU'),
        reason: 'build_pdfium.sh must configure PDFium_TARGET_CPU',
      );
      expect(
        activeScript,
        contains('arm64'),
        reason: 'build_pdfium.sh must build for arm64',
      );
      expect(
        activeScript,
        isNot(contains('arm/arm64/x64')),
        reason:
            'build_pdfium.sh must no longer accept multi-arch arm/x64 selector',
      );
      expect(
        activeScript,
        isNot(contains('!= "x64"')),
        reason: 'build_pdfium.sh must not branch for x64 builds',
      );
    });
  });
}
