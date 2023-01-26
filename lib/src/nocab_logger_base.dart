import 'dart:async';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:nocab_logger/src/database/log.dart';

class Logger {
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;
  Logger._internal();

  final Isar _isar = Isar.openSync([LogSchema], name: 'nocab_logger');

  Stream<void> get onLogged => _isar.logs.watchLazy();

  void _log(LogType logType, String message, String className, Object? error, StackTrace? stackTrace) {
    final log = Log(
      logType: logType,
      message: message,
      className: className,
      dateTime: DateTime.now(),
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
    );

    print(log.toString());
    _isar.writeTxnSync(() => _isar.logs.putSync(log));
  }

  void info(String message, String className, {Object? error, StackTrace? stackTrace}) {
    _log(LogType.info, message, className, error, stackTrace);
  }

  void warning(String message, String className, {Object? error, StackTrace? stackTrace}) {
    _log(LogType.warning, message, className, error, stackTrace);
  }

  void error(String message, String className, {Object? error, StackTrace? stackTrace}) {
    _log(LogType.error, message, className, error, stackTrace);
  }

  Future<List<Log>> get({DateTime? from, DateTime? to, LogType? logType}) async {
    var query = _isar.logs
        .filter()
        .optional(from != null, (q) => q.dateTimeGreaterThan(from!))
        .optional(to != null, (q) => q.dateTimeLessThan(to!))
        .optional(logType != null, (q) => q.logTypeEqualTo(logType!))
        .sortByDateTime();

    return await query.findAll();
  }

  Future<void> exportLogsLast10Days(File file) async {
    final logs = await get(from: DateTime.now().subtract(Duration(days: 10)));
    final string = logs.map((e) => e.toString()).join('\r\n');
    await file.create(recursive: true);
    await file.writeAsString(string);
  }

  Future<void> dispose({bool deleteFromDisk = false}) async {
    await _isar.close(deleteFromDisk: deleteFromDisk);
  }

  Future<void> deleteLogs({DateTime? from, DateTime? to, LogType? logType}) async {
    final logs = await get(from: from, to: to, logType: logType);
    await _isar.writeTxn(() async {
      for (final log in logs) {
        await _isar.logs.delete(log.id);
      }
    });
  }

  /// Only use this method for non-Flutter code or unit tests.
  static Future<void> downloadIsarCore() async {
    await Isar.initializeIsarCore(download: true);
  }
}
