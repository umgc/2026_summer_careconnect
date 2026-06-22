import 'package:care_connect_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../abstracts/file_handler.dart';

class FileHandlerFactory {
  /// This factory to load the correct file loader depending on the platform.
  static FileHandler create(BuildContext context) {
    // Conditional imports handle platform selection
    return _createPlatformHandler(context);
  }
}

// This will be implemented by the platform-specific files
FileHandler _createPlatformHandler(BuildContext context) {
  final t = AppLocalizations.of(context)!;
  // This function will be replaced by the conditional import
  throw UnsupportedError(t.filehandler_invalidPlatform);
}
