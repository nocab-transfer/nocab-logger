import 'dart:io';
import 'dart:math';
import 'package:nocab_logger/nocab_logger.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  group('Logging', () {
    late Directory testLogDir;

    setUp(() async {
      testLogDir = Directory(join(Directory.current.path, 'test', 'logs'));
      if (await testLogDir.exists()) await testLogDir.delete(recursive: true);
      await testLogDir.create(recursive: true);
    });

    test('Basic', () async {
      List<int> randomInt = List.generate(3, (index) => Random().nextInt(100000));
      var logger = Logger("test", storeInFile: true, logPath: testLogDir.path);

      logger.info("test info message ${randomInt[0]}", "test", error: Exception("test error"), stackTrace: StackTrace.current);
      logger.warning("test warning message ${randomInt[1]}", "test", error: Exception("test error"), stackTrace: StackTrace.current);
      logger.error("test error message ${randomInt[2]}", "test", error: Exception("test error"), stackTrace: StackTrace.current);

      await logger.close();

      final logs = await logger.file.readAsLines();
      expect(logs.length, 3);

      print("Checking validity of logs...");
      var stopwatch = Stopwatch()..start();
      var isValid = await Logger.isFileValid(logger.file);
      stopwatch.stop();
      print("Validity check took ${stopwatch.elapsedMilliseconds}ms");

      expect(isValid, true);
    });

    test('Stress Test', () async {
      List<int> randomInt = List.generate(10000, (index) => Random().nextInt(100000));
      var logger = Logger('test', storeInFile: true, logPath: testLogDir.path, printLog: false);

      var stressStopwatch = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        logger.info("test info message ${randomInt[i]}", "test", error: Exception("test error"), stackTrace: StackTrace.current);
        logger.warning("test warning message ${randomInt[i]}", "test", error: Exception("test error"), stackTrace: StackTrace.current);
        logger.error("test error message ${randomInt[i]}", "test", error: Exception("test error"), stackTrace: StackTrace.current);
        logger.fatal("test fatal message ${randomInt[i]}", "test", error: Exception("test error"), stackTrace: StackTrace.current);
      }

      await logger.close();
      stressStopwatch.stop();

      var fileByteSize = await logger.file.length();
      print("Stress test took ${stressStopwatch.elapsedMilliseconds}ms and created a file of size ${(fileByteSize / 1000000).toStringAsFixed(2)}MB."
          "Average write speed: ${(fileByteSize / stressStopwatch.elapsedMilliseconds).toStringAsFixed(2)}KB/s");

      final logs = await logger.file.readAsLines();
      expect(logs.length, 40000);

      print("Checking validity of logs...");
      var validityStopwatch = Stopwatch()..start();
      var isValid = await Logger.isFileValid(logger.file);
      validityStopwatch.stop();
      print("Validity check took ${validityStopwatch.elapsedMilliseconds}ms");

      expect(isValid, true);
    });

    tearDown(() => testLogDir.deleteSync(recursive: true));
  });
}
