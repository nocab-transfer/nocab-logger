# Dart Logger

A simple and flexible logging package for Dart applications. Uses [Isar](https://isar.dev) as database.

## Features
- Multiple log levels (info, warning, error)
- Ability to log to console, file
- Support for adding errors and stackTraces to log entries

## Installation

Add the following to your `pubspec.yaml` file:
```yaml
dependencies:
  dart_logger:
    git: https://github.com/nocab-transfer/nocab-logger.git
```

## Usage
```dart
import 'package:nocab_logger/nocab_logger.dart';

void main() {
  // Logger is a singleton, so you can access it anywhere in your application

  Logger().info('Info message', 'receiver_service');
  Logger().warning('Cannot convert', 'ImageConverter');
  Logger().error('Error message', 'SomeClass', error: e, stackTrace: stackTrace);
}
```

You can fetch the log entries with/without filter:

```dart
// Fetch all log entries
var entries = await Logger().get();

// Fetch all log entries with level 'info'
var entries = await Logger().get(logType: LogType.info);

// Fetch all log entries with level 'info' and between 2020-01-01 and 2020-01-31
var entries = await Logger().get(
  logType: LogType.info,
  from: DateTime(2020, 1, 1),
  to: DateTime(2020, 1, 31),
);
```

To convert last 10 days logs to text file, you can use `exportLogsLast10Days`:

```dart
var file = File('logs.txt');
Logger().exportLogsLast10Days(file);
```

## Example Output
```text
[INFO] 2020-01-01 00:00:00.000 - receiver_service: Info message error \n stacktrace
[WARNING] 2020-01-01 00:00:00.000 - ImageConverter: Cannot convert error \n stacktrace
[ERROR] 2020-01-01 00:00:00.000 - SomeClass: Error message error \n stacktrace
``` 

## Contributing
1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details