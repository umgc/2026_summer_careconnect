import '../abstracts/file_handler.dart';
import '../utils/file_handler_native.dart'
    if (dart.library.html) '../utils/file_handler_web.dart' as platform;

class FileHandlerFactory {
  static FileHandler create() {
    return platform.createPlatformHandler();
  }
}
