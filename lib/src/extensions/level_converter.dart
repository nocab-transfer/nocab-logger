import 'package:logging/logging.dart';
import 'package:nocab_logger/src/models/log_level.dart';

extension Converter on Level {
  LogLevel get logLevel {
    switch (name) {
      case 'INFO':
        return LogLevel.INFO;
      case 'WARNING':
        return LogLevel.WARNING;
      case 'SEVERE':
        return LogLevel.ERROR;
      case 'SHOUT':
        return LogLevel.FATAL;
      default:
        return LogLevel.INFO;
    }
  }
}
