import 'dart:io';

import 'package:intl/intl.dart';
import 'package:nocab_logger/src/models/log.dart';
import 'package:logging/logging.dart' as logging;
import 'package:path/path.dart';

class Logger {
  final String name;
  late logging.Logger _mainLogger;
  late File _file;

  final bool _isClosed = false;
  bool get isClosed => _isClosed;

  File get file => _file;

  IOSink? _sink;
  Logger(this.name, {bool storeInFile = false, String? logPath, bool printLog = true}) : assert(!storeInFile || logPath != null) {
    if (storeInFile) {
      _file = File(join(logPath!, '$name-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.log'))..createSync(recursive: true);
      _sink = _file.openWrite(mode: FileMode.append);
    }

    _mainLogger = logging.Logger.detached(name);
    _mainLogger.onRecord.listen((event) {
      final log = Log.fromLogRecord(event);
      if (printLog) print(log.toString().replaceAll('\\n', '\n'));
      _sink?.writeln(log);
    });
  }

  void info(String message, {Object? error, StackTrace? stackTrace}) {
    if (_isClosed) throw Exception('Logger is closed');
    _mainLogger.info(message, error, stackTrace);
  }

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    if (_isClosed) throw Exception('Logger is closed');
    _mainLogger.warning(message, error, stackTrace);
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (_isClosed) throw Exception('Logger is closed');
    _mainLogger.severe(message, error, stackTrace);
  }

  void fatal(String message, {Object? error, StackTrace? stackTrace}) {
    if (_isClosed) throw Exception('Logger is closed');
    _mainLogger.shout(message, error, stackTrace);
  }

  Future<void> close() async {
    await _sink?.flush();
    await _sink?.close();
  }

  static Future<bool> isFileValid(File file) async {
    if (!await file.exists()) throw Exception('File does not exist');
    if ((await file.length()) > 500000000) throw Exception('File is too big'); // 500 MB

    final lines = await file.readAsLines();
    return lines.every((element) => Log.checkValidity(element));
  }

  static Future<List<Log>> getLogs(File file) async {
    if (!await file.exists()) throw Exception('File does not exist');
    if ((await file.length()) > 500000000) throw Exception('File is too big'); // 500 MB

    final lines = await file.readAsLines();
    return lines.map((e) => Log.fromString(e)).toList();
  }
}
