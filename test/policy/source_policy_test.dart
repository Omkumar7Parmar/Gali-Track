import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source-graph rules no runtime test can see. Each one is decidable from
/// the text, silent when broken, and one line to break.
///
/// Every check strips line comments first, collects all offenders, and
/// fails once with the full list.
void main() {
  final importUri = RegExp(
    r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
    multiLine: true,
  );
  final lineComment = RegExp('//[^\n]*');

  /// Hand-written Dart files under lib/, with comments removed.
  Map<String, String> libSources() {
    final sources = <String, String>{};
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      final path = file.path.replaceAll(r'\', '/');
      if (!path.endsWith('.dart') || path.endsWith('.g.dart')) continue;
      if (path.startsWith('lib/l10n/app_localizations')) continue; // generated
      sources[path] = file.readAsStringSync().replaceAll(lineComment, '');
    }
    return sources;
  }

  List<String> offendingImports(
    bool Function(String path, String uri) isBanned,
  ) {
    return [
      for (final MapEntry(key: path, value: code) in libSources().entries)
        for (final match in importUri.allMatches(code))
          if (isBanned(path, match.group(1)!)) '$path: ${match.group(1)}',
    ];
  }

  test('only lib/data/ touches the database libraries', () {
    const databaseLibraries = ['package:drift', 'package:sqlite3'];
    final offenders = offendingImports(
      (path, uri) =>
          !path.startsWith('lib/data/') &&
          databaseLibraries.any(uri.startsWith),
    );
    expect(
      offenders,
      isEmpty,
      reason:
          'Drift and SQLite stay inside lib/data/; other layers use the value types '
          'in lib/core/models.\n${offenders.join('\n')}',
    );
  });

  test('nothing in lib/ can reach the network or phone home', () {
    const banned = [
      'package:http/',
      'package:dio/',
      'package:firebase',
      'package:sentry',
      'package:google_fonts/',
    ];
    final offenders = offendingImports((_, uri) => banned.any(uri.startsWith));
    expect(
      offenders,
      isEmpty,
      reason:
          'These break the "your walks stay on your phone" promise.\n${offenders.join('\n')}',
    );
  });

  test('lib/core/ stays pure Dart and depends on nothing above it', () {
    const allowedPrefixes = [
      'dart:',
      'package:clock/',
      'package:meta/',
      'package:riverpod/',
      'package:galitrack/core/',
    ];
    final offenders = offendingImports(
      (path, uri) =>
          path.startsWith('lib/core/') && !allowedPrefixes.any(uri.startsWith),
    );
    expect(
      offenders,
      isEmpty,
      reason:
          'core/ is the Flutter-free foundation every layer builds on.\n${offenders.join('\n')}',
    );
  });

  test('features never import each other', () {
    final featureOf = RegExp('^lib/features/([^/]+)/');
    final importedFeature = RegExp('^package:galitrack/features/([^/]+)/');
    final offenders = offendingImports((path, uri) {
      final own = featureOf.firstMatch(path)?.group(1);
      final other = importedFeature.firstMatch(uri)?.group(1);
      return own != null && other != null && own != other;
    });
    expect(
      offenders,
      isEmpty,
      reason:
          'Share code through core/, data/ or ui/, and move between features by route.\n'
          '${offenders.join('\n')}',
    );
  });

  test(
    'raw colours, curves, durations, radii and font sizes live only in lib/theme/',
    () {
      final rawValue = RegExp(
        r'Color\(0x|\bColors\.(?!transparent)|Curves\.|Duration\((?:milliseconds|seconds):|'
        r'BorderRadius\.circular\(\d|fontSize:\s*\d',
      );
      final offenders = [
        for (final MapEntry(key: path, value: code) in libSources().entries)
          if (!path.startsWith('lib/theme/'))
            for (final match in rawValue.allMatches(code))
              '$path: ${match.group(0)}',
      ];
      expect(
        offenders,
        isEmpty,
        reason:
            'Add a token in lib/theme/ instead, so a reskin is one directory.\n${offenders.join('\n')}',
      );
    },
  );
}
