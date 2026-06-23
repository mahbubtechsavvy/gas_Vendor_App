class ApiConfig {
  /// Set to true to use demo/offline mode (no backend required)
  /// Set to false to connect to actual backend server
  static const bool useDemoMode = false;

  // Base URL for your PHP backend
  static const String baseUrl = 'https://gaslagbaadmin.gtgroup.cloud/api/v1';

  // InfinityFree Security Bypass Cookie (REMOVED - Not needed for AwardSpace)

  // Alternative for testing with localhost
  // Android Emulator: http://10.0.2.2/gas_delivery/api/v1
  // iOS Simulator: http://localhost/gas_delivery/api/v1

  // API Endpoints (relative to baseUrl)
  static const String auth = '/auth';
  static const String vendors = '/vendor';
  static const String products = '/products';
  static const String orders = '/orders';
  static const String dashboard = '/vendor/dashboard';
  static const String prescriptions = '/vendor/prescriptions';
  static const String sales = '/vendor/sales';
  static const String notifications = '/notifications';
  static const String profile = '/vendor/profile';
  static const String updateProfile = '/vendor/update_profile.php';

  // Authentication Endpoints (relative to baseUrl)
  static const String login = '/auth/login.php';
  static const String register = '/auth/register.php';
  static const String sendOtp = '/auth/send-otp.php';
  static const String verifyOtp = '/auth/verify-otp.php';
  static const String forgotPassword = '/auth/forgot-password.php';
  static const String logout = '/auth/logout.php';

  // Request Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String vendorKey = 'vendor_data';
  static const String isLoggedInKey = 'is_logged_in';
}
