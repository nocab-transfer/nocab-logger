import 'package:nocab_logger/src/models/log_level.dart';

class Log {
  final LogLevel level;
  final String message;
  final String loggerName;
  final String? className;
  final Object? error;
  final StackTrace? stackTrace;
  late DateTime time;

  Log(this.level, this.message, this.loggerName, {this.className, this.error, this.stackTrace, DateTime? time}) : time = time ?? DateTime.now();

  // Level, Time, Classname, Message are required. Error and StackTrace are optional
  static final String _regex = r'\[(?<level>'
      '${LogLevel.values.map((e) => e.name).join('|')}' // get all the log levels dynamically
      r')\] - (?<time>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{0,}) (?<loggerName>\S[^\.\:]+)(?:\.(?<classname>\S[^\:]+))?: (?<message>\S[^\[]+) ?(?:\[(?<error>\S[^\[]+)\])? ?(?:\[StackTrace: (?<stackTrace>\S[^\]]+)?\])?';

  @override
  String toString() {
    return '[${level.name}] - ${time.toIso8601String()} $loggerName${className != null ? '.$className' : ''}: $message ${error != null ? '[$error]' : ''} ${stackTrace != null ? '[StackTrace: ${stackTrace.toString().trim()}]' : ''}';
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
    String loggerName = match.namedGroup('loggerName')!.replaceAll('\\n', '\n').replaceAll('\\r', '\r');
    String? classname = match.namedGroup('classname')?.replaceAll('\\n', '\n').replaceAll('\\r', '\r');
    String message = match.namedGroup('message')!.replaceAll('\\n', '\n').replaceAll('\\r', '\r');
    Object? error = match.namedGroup('error')?.replaceAll('\\n', '\n').replaceAll('\\r', '\r');
    StackTrace? stackTrace =
        match.namedGroup('stackTrace') != null ? StackTrace.fromString(match.namedGroup('stackTrace')!.replaceAll('\\n', '\n')) : null;
    return Log(LogLevel.values.firstWhere((e) => e.name == level), message, loggerName,
        className: classname, error: error, stackTrace: stackTrace, time: time);
  }
}
