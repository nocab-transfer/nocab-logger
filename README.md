# NoCab Logger

A simple and flexible logging package created for NoCab Transfer.

## Features
- Multiple log levels (info, warning, error, fatal)
- Ability to write logs to file
- Support for adding errors and stackTraces to log entries
- Logging between other isolates

## Installation

Add the following to your `pubspec.yaml` file:
```yaml
dependencies:
  nocab_logger:
    git: https://github.com/nocab-transfer/nocab-logger.git
```

## Usage
```dart
import 'package:nocab_logger/nocab_logger.dart';

void main() async {
  // If you want to store logs in file, you need to specify the path
  var logger = Logger("MainLogger", storeInFile: true, logPath: "path/to/logs/folder");

  logger.info("Info message", className: "main");
  logger.warning("Warning message", className: "main", error: Exception("test error"), stackTrace: StackTrace.current);
  logger.error("Error message", className: "main", error: Exception("test error"), stackTrace: StackTrace.current);
  logger.fatal("Fatal message", className: "main", error: Exception("test error"), stackTrace: StackTrace.current);

  logger.close();
}
```

You can fetch the log entries from the file using the `getLogs` method:

```dart
// If you want to fetch all logs, the logger should be created with storeInFile: true
var logger = Logger("MainLogger", storeInFile: true, logPath: "path/to/logs/folder");

// check if the file is valid
if (await Logger.isFileValid(logger.file!)) {
  var logs = await Logger.getLogs(logger.file!);
  print(logs);
}

logger.close();
```

## Example Output
```text
[INFO] - 2023-02-27T20:01:27.946352 MainLogger.main: Info message
[WARNING] - 2023-02-27T20:01:27.946352 MainLogger.main: Warning message [Exception: test error] [StackTrace: #0      main (file:///Users/username/Projects/nocab-logger/example/main.dart:10:5)]
[ERROR] - 2023-02-27T20:01:27.946352 MainLogger.main: Error message [Exception: test error] [StackTrace: #0      main (file:///Users/username/Projects/nocab-logger/example/main.dart:11:5)]
[FATAL] - 2023-02-27T20:01:27.946352 MainLogger.main: Fatal message [Exception: test error] [StackTrace: #0      main (file:///Users/username/Projects/nocab-logger/example/main.dart:12:5)]
``` 

## Contributing
1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details