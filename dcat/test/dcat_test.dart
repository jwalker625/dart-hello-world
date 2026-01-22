import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('dcat CLI', () {
    group('no argument provided', () {
      test('prints lines from stdin', () async {
        final process = await Process.start('dart', ['run', 'bin/dcat.dart']);
        process.stdin.writeAll([
          'Hello World!\n',
          'This is line two.\n',
          'Third line here.\n',
        ]);
        await process.stdin.close();

        final exitCode = await process.exitCode;
        expect(exitCode, equals(0));
        final result = await process.stdout.transform(utf8.decoder).join();
        expect(
          result,
          equals('''
Hello World!
This is line two.
Third line here.
'''),
        );
      });
    });

    group('one file provided as argument', () {
      test('prints lines from file, when called with no flags', () async {
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

      test('prints numbered lines, when -n flag received', () async {
        final result = await Process.run('dart', [
          'run',
          'bin/dcat.dart',
          '-n',
          'test/fixtures/example.txt',
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

      test('prints nothing, when file is empty', () async {
        final result = await Process.run('dart', [
          'run',
          'bin/dcat.dart',
          'test/fixtures/empty.txt',
        ]);

        expect(result.exitCode, equals(0));
        expect(result.stdout, isEmpty);
      });
    });

    group('multiple files provided as arguments', () {
      test(
        'prints lines from all files sequentially, when called with no flags',
        () async {
          final result = await Process.run('dart', [
            'run',
            'bin/dcat.dart',
            'test/fixtures/example.txt',
            'test/fixtures/another_example.txt',
          ]);

          expect(result.exitCode, equals(0));
          expect(
            result.stdout,
            equals('''
Hello World!
This is line two.
Third line here.
Here's another file.
And its second line.
'''),
          );
        },
      );

      test(
        'prints numbered lines from all files sequentially, when -n flag received',
        () async {
          final result = await Process.run('dart', [
            'run',
            'bin/dcat.dart',
            '-n',
            'test/fixtures/example.txt',
            'test/fixtures/another_example.txt',
          ]);

          expect(result.exitCode, equals(0));
          expect(
            result.stdout,
            equals('''
1 Hello World!
2 This is line two.
3 Third line here.
1 Here's another file.
2 And its second line.
'''),
          );
        },
      );
    });

    group('invalid argument provided', () {
      test(
        'returns exit code 2, when unrecognized file provided as argument',
        () async {
          final result = await Process.run('dart', [
            'run',
            'bin/dcat.dart',
            'nonexistent.txt',
          ]);

          expect(result.exitCode, equals(2));
        },
      );

      test(
        'returns exit code 2, when directory provided as argument',
        () async {
          final result = await Process.run('dart', [
            'run',
            'bin/dcat.dart',
            'test/fixtures',
          ]);

          expect(result.exitCode, equals(2));
        },
      );

      test(
        'prints error message to stderr, when directory provided as argument',
        () async {
          final result = await Process.run('dart', [
            'run',
            'bin/dcat.dart',
            'test/fixtures',
          ]);

          expect(
            result.stderr,
            equals('''
error: test/fixtures is a directory
'''),
          );
        },
      );
    });
  });
}
