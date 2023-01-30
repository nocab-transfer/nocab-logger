// ignore_for_file: constant_identifier_names

import 'package:logging/logging.dart';

enum LogLevel {
  INFO(Level.INFO),
  WARNING(Level.WARNING),
  ERROR(Level.SEVERE),
  FATAL(Level.SHOUT);

  final Level loggingLevel;
  const LogLevel(this.loggingLevel);
}
