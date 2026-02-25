import 'log_file_writer.dart';

LogFileWriter createLogFileWriter() => WebLogFileWriter._();

class WebLogFileWriter implements LogFileWriter {
  WebLogFileWriter._();

  @override
  String? get filePath => null;

  @override
  void write(String line) {
    // No-op on web — console logging via AppLogger (developer.log + debugPrint)
    // continues to work without file output.
  }
}
