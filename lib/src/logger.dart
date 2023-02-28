import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:intl/intl.dart';
import 'package:nocab_logger/src/models/log.dart';
import 'package:nocab_logger/src/models/log_level.dart';
import 'package:path/path.dart';

class Logger {
  final String name;
  late File? _file;

  File? get file => _file;

  final StreamController<Log> _controller = StreamController<Log>.broadcast();
  Stream<Log> get onLogged => _controller.stream;

  final ReceivePort _receivePort = ReceivePort();

  /// Use this to send logs to this logger from another isolate.
  ///
  /// Example:
  /// ```
  /// Logger logger = Logger('MyLogger');
  /// logger.sendPort.send(Log(LogLevel.info, 'Hello from another isolate', 'MyLogger'));
  /// ```
  /// loggerName will be overridden with the name of this logger.
  SendPort get sendPort => _receivePort.sendPort;

  IOSink? _sink;

  /// Creates a new Logger object.
  ///
  /// A [Logger] is used to log events to a log file and to the console.
  ///
  /// The [name] parameter is used to identify the logger. It is used as the
  /// prefix for all log messages.
  ///
  /// If [storeInFile] is true, the log messages will be saved to a file.
  ///
  /// The [logPath] parameter specifies the path to the folder where the log
  /// file should be saved. It will be ignored if [storeInFile] is false.
  ///
  /// If [printLog] is true, the log messages will be printed to the console.
  ///
  /// Throws a [FormatException] if the [name] is invalid.
  ///
  /// Throws a [StateError] if [storeInFile] is true and [logPath] is null.
  ///
  /// Throws a [FileSystemException] if the log file cannot be created.
  Logger(this.name, {bool storeInFile = false, String? logPath, bool printLog = true})
      : assert(!storeInFile || logPath != null, 'logPath cannot be null if storeInFile is true'),
        assert(!name.endsWith('.') && !name.startsWith('.'), 'Logger name cannot start or end with a dot (.)'),
        assert(name.length >= 2, 'Logger name must be at least 2 characters long'),
        assert(!name.contains(':'), 'Logger name cannot contain a colon (:)') {
    if (storeInFile) {
      DateTime now = DateTime.now();
      _file = File(join(logPath!, '$name-${DateFormat('yyyyMMddTHHmmss', 'en_US').format(now)}-${now.millisecond}.log'))..createSync(recursive: true);
      _sink = _file?.openWrite(mode: FileMode.append);
    }

    onLogged.listen((log) {
      if (printLog) print(log.toString());
      _sink?.writeln(log.toString().replaceAll('\n', '\\n').replaceAll('\r', '\\r'));
    });

    _receivePort.listen((message) {
      if (message is Log) {
        _log(message.level, message.message, className: message.className, error: message.error, stackTrace: message.stackTrace);
      } else {
        warning('Received invalid message from isolate: $message', className: 'Logger');
      }
    });
  }

  void _log(LogLevel level, String message, {String? className, Object? error, StackTrace? stackTrace}) {
    if (className != null && className.length < 2) throw FormatException('Class name must be at least 2 characters long');
    if (_controller.isClosed) return;

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
    _receivePort.close();
    await _controller.close();
    await _sink?.flush();
    await _sink?.close();
    if (deleteFile) await _file?.delete();
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
