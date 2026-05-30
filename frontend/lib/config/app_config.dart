import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'env_constant.dart' as env;

/// Global app configuration for environment variables and settings
class AppConfig {
  /// Google Places API Key for address autocomplete
  static String getGooglePlacesApiKey() {
    return dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
  }

  /// Backend base URL
  static String getBackendBaseUrl() {
    return env.getBackendBaseUrl();
  }

  /// Apple Merchant ID for Apple Pay
  static String getAppleMerchantId() {
    return dotenv.env['APPLE_MERCHANT_ID'] ?? '';
  }

  /// Google Pay Merchant ID
  static String getGooglePayMerchantId() {
    return dotenv.env['GOOGLE_PAY_MERCHANT_ID'] ?? '';
  }

  /// Check if Google Places API key is configured
  static bool isGooglePlacesConfigured() {
    final key = getGooglePlacesApiKey();
    return key.isNotEmpty && !key.contains('your_google_places_api_key');
  }
}
