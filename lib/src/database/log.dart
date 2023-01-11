import 'package:isar/isar.dart';

part 'log.g.dart';

@collection
class Log {
  Id id = Isar.autoIncrement;

  @enumerated
  LogType logType;

  String message;

  String className;

  DateTime dateTime;

  String? error;

  String? stackTrace;

  Log({required this.logType, required this.message, required this.dateTime, required this.className, this.error, this.stackTrace});

  @override
  String toString() {
    return '[${logType.name.toUpperCase()}] ${dateTime.toIso8601String()} - $className: $message ${error != null ? '- $error' : ''} ${stackTrace != null ? '\n$stackTrace' : ''}';
  }
}

enum LogType {
  info,
  warning,
  error,
}
