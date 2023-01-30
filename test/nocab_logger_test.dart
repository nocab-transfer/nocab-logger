import 'dart:math';

import 'package:isar/isar.dart';
import 'package:nocab_logger/nocab_logger.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() async {
      await Isar.initializeIsarCore(download: true);
    });

    test('Log', () async {
      List<int> randomInt = List.generate(3, (index) => Random().nextInt(100000));

      Logger().info("test info message ${randomInt[0]}", "test");
      Logger().warning("test warning message ${randomInt[1]}", "test");
      Logger().error("test error message ${randomInt[2]}", "test");

      final logs = await Logger().get();
      expect(logs.length, 3);
      expect(logs[0].message, "test info message ${randomInt[0]}");
      expect(logs[1].message, "test warning message ${randomInt[1]}");
      expect(logs[2].message, "test error message ${randomInt[2]}");
    });

    // dispose
    tearDown(() async {
      await Logger().dispose(deleteFromDisk: true);
    });
  });
}
