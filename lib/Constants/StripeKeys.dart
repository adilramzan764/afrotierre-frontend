// lib/constants/stripe_keys.dart
class StripeKeys {
  // Development/Test Key
  // static const String testPublishableKey = 'pk_test_51QLCHLK9EqB8Mu5GI6bxjrr0PwovKhBA16jsGySXckXlXSylBfvuFa9daQU9b8rJXuSGWPENmccX1q1r4puEABf100HJ3rKVtW';

  // Production Live Key (uncomment when going to production)
  static const String livePublishableKey = 'pk_live_51QLCHLK9EqB8Mu5GsmU91Csido0RLoyHUVIXkw2EYavzN3WQTKLev5tB2wxu9wt7hWgx6RuVTFTPS12XAyjJPlJB00TGRAAmzD';

  // Get current key based on build mode
  static String getPublishableKey() {
    // In debug mode, use test key
    // In release mode, use live key
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    // return isProduction ? livePublishableKey : testPublishableKey;
    return livePublishableKey; // Using test key for now
  }
}