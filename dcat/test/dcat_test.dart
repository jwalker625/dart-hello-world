import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('dcat CLI', () {
    test('prints lines from stdin, when no files provided', () {
      final process = Process.start('dart', ['run', 'bin/dcat.dart']);
    });

    test('prints numbered lines when -n', () async {
      final result = await Process.run('dart', [
        'run',
        'bin/dcat.dart',
        'test/fixtures/example.txt',
        '-n',
      ]);

      expect(result.exitCode, equals(0));
      expect(
        result.stdout,
        equals('''
1 Hello World!
2 This is line two.
3 Third line here.
'''),
      );
    });

    test('prints lines when -n not passed', () async {
      final result = await Process.run('dart', [
        'run',
        'bin/dcat.dart',
        'test/fixtures/example.txt',
      ]);

      expect(result.exitCode, equals(0));
      expect(
        result.stdout,
        equals('''
Hello World!
This is line two.
Third line here.
'''),
      );
    });
  });
}
