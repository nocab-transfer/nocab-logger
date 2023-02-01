import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:nocab_logger/src/models/log.dart';
import 'package:nocab_logger/src/models/log_level.dart';
import 'package:path/path.dart';

class Logger {
  final String name;
  late File _file;

  final bool _isClosed = false;
  bool get isClosed => _isClosed;

  File get file => _file;

  final StreamController<Log> _controller = StreamController<Log>.broadcast();
  Stream<Log> get onLogged => _controller.stream;

  IOSink? _sink;
  Logger(this.name, {bool storeInFile = false, String? logPath, bool printLog = true}) : assert(!storeInFile || logPath != null) {
    if (name.endsWith('.') || name.startsWith('.')) throw FormatException('Logger name cannot start or end with a dot (.)');
    if (name.contains(':')) throw FormatException('Logger name cannot contain a colon (:)');
    if (name.length < 2) throw FormatException('Logger name must be at least 2 characters long');

    if (storeInFile) {
      _file = File(join(logPath!, '$name-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.log'))..createSync(recursive: true);
      _sink = _file.openWrite(mode: FileMode.append);
    }

    onLogged.listen((log) {
      if (printLog) print(log.toString());
      _sink?.writeln(log.toString().replaceAll('\n', '\\n'));
    });
  }

  factory Logger.fromFile(File file) {
    if (!file.path.endsWith('.log')) throw FormatException('File must be a .log file');
    if (!basenameWithoutExtension(file.path).contains('-')) throw FormatException('File is not a valid log file');
    if (!Logger.isFileValidSync(file)) throw FormatException('File is not a valid log file');

    String name = basenameWithoutExtension(file.path).split('-').first;
    return Logger(name, storeInFile: true, logPath: dirname(file.path));
  }

  void _log(LogLevel level, String message, {String? className, Object? error, StackTrace? stackTrace}) {
    if (className != null && className.length < 2) throw FormatException('Class name must be at least 2 characters long');
    if (_isClosed) throw Exception('Logger is closed');
    _controller.add(Log(level, message, name, className: className, error: error, stackTrace: stackTrace));
  }

  void info(String message, {String? className, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.INFO, message, className: className, error: error, stackTrace: stackTrace);
  }

  void warning(String message, {String? className, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.WARNING, message, className: className, error: error, stackTrace: stackTrace);
  }

  void error(String message, {String? className, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.ERROR, message, className: className, error: error, stackTrace: stackTrace);
  }

  void fatal(String message, {String? className, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.FATAL, message, className: className, error: error, stackTrace: stackTrace);
  }

  Future<void> close({bool deleteFile = false}) async {
    await _controller.close();
    await _sink?.flush();
    await _sink?.close();
    if (deleteFile) await _file.delete();
  }

  static Future<bool> isFileValid(File file) async {
    if (!await file.exists()) throw Exception('File does not exist');
    if ((await file.length()) > 500000000) throw Exception('File is too big'); // 500 MB

    final lines = await file.readAsLines();
    return lines.every((element) => Log.checkValidity(element));
  }

  static bool isFileValidSync(File file) {
    if (!file.existsSync()) throw Exception('File does not exist');
    if (file.lengthSync() > 500000000) throw Exception('File is too big'); // 500 MB

    final lines = file.readAsLinesSync();
    return lines.every((element) => Log.checkValidity(element));
  }

  static Future<List<Log>> getLogs(File file) async {
    if (!await file.exists()) throw Exception('File does not exist');
    if ((await file.length()) > 500000000) throw Exception('File is too big'); // 500 MB

    final lines = await file.readAsLines();
    return lines.map((e) => Log.fromString(e)).toList();
  }
}
