import 'package:logging/logging.dart';
import 'package:nocab_logger/src/extensions/level_converter.dart';
import 'package:nocab_logger/src/models/log_level.dart';

class Log {
  final LogLevel level;
  final String message;
  final String loggerName;
  final Object? error;
  final StackTrace? stackTrace;
  late DateTime time;

  Log(this.level, this.message, this.loggerName, {this.error, this.stackTrace, DateTime? time}) : time = time ?? DateTime.now();

  factory Log.fromLogRecord(LogRecord record) {
    return Log(record.level.logLevel, record.message, record.loggerName, error: record.error, stackTrace: record.stackTrace, time: record.time);
  }

  // Level, Time, Classname, Message are required. Error and StackTrace are optional
  static final String _regex = r'\[(?<level>'
      '${LogLevel.values.map((e) => e.name).join('|')}' // get all the log levels dynamically
      r')\] - (?<time>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{0,}) (?<classname>.*?): (?<message>[\w\W][^\[]+) ?(?:\[(?<error>[\w\W][^\[]+)\])? ?(?:\[StackTrace: (?<stackTrace>[\w\W][^\]]+)?\])?';

  @override
  String toString() {
    return '[${level.name}] - ${time.toIso8601String()} $loggerName: $message ${error != null ? '[$error]' : ''} ${stackTrace != null ? '[StackTrace: ${stackTrace.toString().trim()}]' : ''}'
        .replaceAll('\n', '\\n');
  }

  static bool checkValidity(String logLine) {
    RegExp regExp = RegExp(_regex, multiLine: true);
    return regExp.hasMatch(logLine);
  }

  factory Log.fromString(String string) {
    RegExp regExp = RegExp(_regex, multiLine: true);
    RegExpMatch? match = regExp.firstMatch(string);
    if (match == null) throw Exception('Invalid log line');

    String level = match.namedGroup('level')!;
    DateTime time = DateTime.parse(match.namedGroup('time')!);
    String classname = match.namedGroup('classname')!.replaceAll('\\n', '\n');
    String message = match.namedGroup('message')!.replaceAll('\\n', '\n');
    Object? error = match.namedGroup('error')?.replaceAll('\\n', '\n');
    StackTrace? stackTrace =
        match.namedGroup('stackTrace') != null ? StackTrace.fromString(match.namedGroup('stackTrace')!.replaceAll('\\n', '\n')) : null;
    return Log(LogLevel.values.firstWhere((e) => e.name == level), message, classname, error: error, stackTrace: stackTrace, time: time);
  }
}
