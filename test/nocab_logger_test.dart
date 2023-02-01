import 'dart:io';
import 'dart:math';
import 'package:nocab_logger/nocab_logger.dart';
import 'package:nocab_logger/src/models/log.dart';
import 'package:nocab_logger/src/models/log_level.dart';
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
      List<int> randomInt = List.generate(4, (index) => Random().nextInt(100000));
      var logger = Logger("test", storeInFile: true, logPath: testLogDir.path);

      logger.info("test info message ${randomInt[0]}", className: "test", error: Exception("test error"), stackTrace: StackTrace.current);
      logger.warning("test warning message ${randomInt[1]}", className: "test", error: Exception("test error"), stackTrace: StackTrace.current);
      logger.error("test error message ${randomInt[2]}", className: "test", error: Exception("test error"), stackTrace: StackTrace.current);
      logger.fatal("test fatal message ${randomInt[3]}", className: "test", error: Exception("test error"), stackTrace: StackTrace.current);

      await logger.close();

      final logs = await logger.file.readAsLines();
      expect(logs.length, 4);

      print("Checking validity of logs...");
      var stopwatch = Stopwatch()..start();
      var isValid = await Logger.isFileValid(logger.file);
      stopwatch.stop();
      print("Validity check took ${stopwatch.elapsedMilliseconds}ms");

      expect(isValid, true);
    });

    test('From String', () async {
      String logString =
          r"[ERROR] - 2023-01-31T15:48:21.804606 test: test error message 44400 [Exception: test error] [StackTrace: #0      main.<anonymous closure>.<anonymous closure> (file:///C:/Users/berke/Desktop/Projects/nocab_logger/test/nocab_logger_test.dart:47:123)\n#1      Declarer.test.<anonymous closure>.<anonymous closure> (package:test_api/src/backend/declarer.dart:215:19)\n<asynchronous suspension>\n#2      StackZoneSpecification._registerUnaryCallback.<anonymous closure> (package:stack_trace/src/stack_zone_specification.dart:124:15)\n<asynchronous suspension>]";
      Log log = Log.fromString(logString);

      expect(log.level, LogLevel.ERROR);
      expect(log.message, "test error message 44400 ");
      expect(log.error, "Exception: test error");
      expect(log.stackTrace.toString(),
          '#0      main.<anonymous closure>.<anonymous closure> (file:///C:/Users/berke/Desktop/Projects/nocab_logger/test/nocab_logger_test.dart:47:123)\n#1      Declarer.test.<anonymous closure>.<anonymous closure> (package:test_api/src/backend/declarer.dart:215:19)\n<asynchronous suspension>\n#2      StackZoneSpecification._registerUnaryCallback.<anonymous closure> (package:stack_trace/src/stack_zone_specification.dart:124:15)\n<asynchronous suspension>');
    });

    test('From File', () async {
      List<int> randomInt = List.generate(4, (index) => Random().nextInt(100000));
      var logger = Logger("test", storeInFile: true, logPath: testLogDir.path, printLog: false);

      logger.info("test info message ${randomInt[0]}", className: "test", error: Exception("test error"), stackTrace: StackTrace.current);
      logger.warning("test warning message ${randomInt[1]}", className: "test", error: Exception("test error"), stackTrace: StackTrace.current);
      logger.error("test error message ${randomInt[2]}", className: "test", error: Exception("test error"), stackTrace: StackTrace.current);
      logger.fatal("test fatal message ${randomInt[3]}", className: "test", error: Exception("test error"), stackTrace: StackTrace.current);

      await logger.close();

      List<Log> fetchedLogs = await Logger.getLogs(logger.file);

      expect(fetchedLogs.length, 4);

      for (int i = 0; i < 4; i++) {
        expect(fetchedLogs[i].level, LogLevel.values[i]);
        expect(fetchedLogs[i].message, "test ${LogLevel.values[i].toString().split('.').last.toLowerCase()} message ${randomInt[i]} ");
        expect(fetchedLogs[i].error, "Exception: test error");
        expect(fetchedLogs[i].stackTrace != null, true);
      }
    });

    test('Stress Test', () async {
      List<int> randomInt = List.generate(10000, (index) => Random().nextInt(100000));
      var logger = Logger('test', storeInFile: true, logPath: testLogDir.path, printLog: false);

      var stressStopwatch = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        logger.info("test info message ${randomInt[i]}", className: "test", error: Exception("test error"), stackTrace: StackTrace.current);
        logger.warning("test warning message ${randomInt[i]}", className: "test", error: Exception("test error"), stackTrace: StackTrace.current);
        logger.error("test error message ${randomInt[i]}", className: "test", error: Exception("test error"), stackTrace: StackTrace.current);
        logger.fatal("test fatal message ${randomInt[i]}", className: "test", error: Exception("test error"), stackTrace: StackTrace.current);
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
