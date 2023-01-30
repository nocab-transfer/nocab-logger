import 'package:logging/logging.dart';
import 'package:nocab_logger/src/extensions/level_converter.dart';
import 'package:nocab_logger/src/models/log_level.dart';

class Log extends LogRecord {
  Log(LogLevel level, String message, String loggerName, {Object? error, StackTrace? stackTrace})
      : super(level.loggingLevel, message, loggerName, error, stackTrace);

  Log.fromLogRecord(LogRecord record) : super(record.level, record.message, record.loggerName, record.error, record.stackTrace);

  // Level, Time, Classname, Message are required. Error and StackTrace are optional
  static final String _regex = r'\[(?<level>'
      '${LogLevel.values.map((e) => e.name).join('|')}' // get all the log levels dynamically
      r')\] - (?<time>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{0,}) (?<classname>.*?): (?<message>[\w\W][^\[]+) ?(?:\[(?<error>[\w\W][^\[]+)\])? ?(?:\[(?<stackTrace>[\w\W][^\]]+)?\])?';

  @override
  String toString() {
    return '[${level.logLevel.name}] - ${time.toIso8601String()} $loggerName: $message ${error != null ? '[$error]' : ''} ${stackTrace != null ? '[$stackTrace]' : ''}'
        .replaceAll('\n', '\\n');
  }

  static bool checkValidity(String logLine) {
    RegExp regExp = RegExp(_regex, multiLine: true);
    return regExp.hasMatch(logLine);
  }

  /*Log fromString(String string)  {
    RegExp regExp = RegExp(r'\[(\w+)\] - (\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}) (\w+): (.+) (\[\w+\])? (\[\w+\])?');
    // \[(?P<level>INFO|WARNING|ERROR)\] - (?P<time>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{0,} (?P<classname>.*): (?P<message>[\w\s]+)) \[(?P<error>[\w\s]+.+)\]? \[(?P<stacktrace>.*)\]?
  }*/
}
