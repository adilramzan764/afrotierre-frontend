// lib/constants/api_constants.dart
class ApiConstants {
  // Base URL - Change this based on environment
  // static const String baseUrlSeller = 'https://your-api-domain.com/api/seller';

  // For development
  static const String baseUrlSeller = 'http://184.72.76.52/api/seller';
  // static const String baseUrlSeller = 'http://192.168.100.170:5000/api/seller';

  static const String baseUrlBuyer = 'http://184.72.76.52/api/buyer';
  // static const String baseUrlBuyer = 'http://192.168.100.170:5000/api/buyer';

  // For staging
  // static const String baseUrlSeller = 'https://staging-api.yourdomain.com/api/seller';

  // Authentication Endpoints
  static const String createWallet = '/auth/create-wallet';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendOTP = '/auth/resend-otp';
  static const String submitStoreDetails = '/auth/submit-store-details';
  static const String addPickupAddress = '/auth/add-pickup-address';
  static const String getPickupAddresses = '/auth/pickup-addresses';



  static const String login = '/auth/login';
  static const String checkToken = '/auth/check-token';
  static const String getRegistrationStep = '/auth/registration-step';
  static const String getProfile = '/auth/profile';
  static const String updateProfile = '/auth/profile';

  // NEW GOOGLE AUTH ENDPOINTS
  static const String googleAuth = '/auth/google';
  static const String linkGoogle = '/auth/google/link';
  static const String unlinkGoogle = '/auth/google/unlink';

  static const String appleAuth = '/auth/auth/apple';
  static const String linkApple = '/auth/auth/apple/link';
  static const String unlinkApple = '/auth/auth/apple/unlink';
  static const String refreshToken = '/auth/refresh-token';

  // Password reset endpoints
  static const String passwordReset_sendOTP = '/password-reset/forgot-password';
  static const String sendOTP = '/seller/password-reset/send-otp';
  static const String verifyOTP = '/password-reset/verify-otp';
  static const String passwordReset_resendOTP = '/password-reset/resend-otp';

  static const String resetPassword = '/password-reset/reset-password';
  static const String changePassword = '/password-reset/change-password';


  // Product endpoints
  static const String createProduct = '/products/addproduct';
  static const String getSellerProducts = '/products/getproducts';
  static const String getProduct = '/products';
  static const String updateProduct = '/products/updateproduct';
  static const String deleteProductImage = '/products/deleteimage';
  static const String archiveProduct = '/products/archive';
  static const String deleteProduct = '/products';
  static const String getProductStats = '/products/stats';
  static const String updateStock = '/products/stock';
  static const String getProductsByCategory = '/products/category';
  static const String getSellerAllowedCategories = '/products/categories';
  static const String publishProduct = '/products/publish';
  static const String unpublishProduct = '/products/unpublish';


  //Buyer endpoints
  static const String submitprofile = '/auth/submit-profile';
  static const String login_buyer = '/auth/login';
  static const String checkToken_buyer = '/auth/check-token';
  static const String refreshToken_buyer = '/auth/refresh-token'; // Added this

  static const String googleAuthBuyer = '/auth/google-auth';
  static const String linkGoogleBuyer = '/auth/link-google';
  static const String unlinkGoogleBuyer = '/auth/unlink-google';

  static const String appleAuthBuyer = '/auth/apple-auth';
  static const String linkAppleBuyer = '/auth/link-apple';
  static const String unlinkAppleBuyer = '/auth/unlink-apple';


// Buyer Home endpoints
  static const String home = '/home';
  static const String products = '/products';
  static const String productDetails = '/products'; // Use with /{id}
  static const String search = '/products/search';
  static const String categories = '/categories';
  static const String categoryProducts = '/categories'; // Use with /{categoryId}/products
  static const String filters = '/filters';


  static const String buyerSendOTP = '/password-reset/send-otp';
  static const String buyerVerifyOTP = '/password-reset/verify-otp';
  static const String buyerResetPassword = '/password-reset/reset';
  static const String buyerResendOTP = '/password-reset/resend-otp';
  static const String buyerChangePassword = '/change-password';

  static const String addToCart = '/auth/cart/add';
  static const String removeFromCart = '/auth/cart/remove'; // Use with /{productId}
  static const String getCart = '/auth/cart';
  static const String updateCart = '/auth/cart/update';
  static const String clearCart = '/auth/cart/clear';


  // Payment Endpoints
  static const String setupCustomer = '/payment/setup-customer';
  static const String addPaymentMethod = '/payment/add-payment-method';
  static const String getPaymentMethods = '/payment/payment-methods';
  static const String setDefaultPaymentMethod = '/payment/payment-methods'; // Use with /{id}/default
  static const String removePaymentMethod = '/payment/payment-methods'; // Use with /{id}
  static const String createPaymentIntent = '/payment/create-payment-intent';
  static const String getPaymentIntentStatus = '/payment/payment-intent'; // Use with /{id}

}

