import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/diagnostics/diagnostics.dart';
import 'package:logging/logging.dart';

void main() {
  test('the log rotates at its size limit and keeps 3 files, oldest first on export', () async {
    final dir = await Directory.systemTemp.createTemp('kakeibo_logs');
    addTearDown(() => dir.delete(recursive: true));
    // 10 KB files stand in for the app's 1 MB, to keep the test fast.
    await Diagnostics.init(dir: dir, maxBytes: 10 * 1024);

    final log = Logger('test');
    final line = 'x' * 100;
    // About 45 KB in total: more than three files' worth.
    for (var i = 0; i < 400; i++) {
      log.info('$i $line');
    }
    log.severe('the last one', StateError('boom'));

    final files = dir.listSync().whereType<File>().toList();
    expect(files.length, Diagnostics.files);
    for (final f in files) {
      expect(f.lengthSync(), lessThan(Diagnostics.maxBytes + 1024));
    }

    final all = await Diagnostics.collect();
    expect(all.trimRight(), endsWith('the last one | Bad state: boom'));
    expect(all.contains('test: 0 '), isFalse, reason: 'the oldest lines were dropped');
    final firstNumber = int.parse(RegExp(r'test: (\d+) ').firstMatch(all)![1]!);
    final lastNumber = int.parse(RegExp(r'test: (\d+) ').allMatches(all).last[1]!);
    expect(firstNumber, lessThan(lastNumber), reason: 'oldest first');
  });
}
