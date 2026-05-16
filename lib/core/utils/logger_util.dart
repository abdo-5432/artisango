import 'package:logger/logger.dart';

class LoggerUtil {
  final Logger _logger = Logger();

  void d(String message) => _logger.d(message);
  void i(String message) => _logger.i(message);
  void w(String message) => _logger.w(message);
  void e(String message, [dynamic error, StackTrace? stackTrace]) => _logger.e(message, error, stackTrace);
}
