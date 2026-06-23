class AppConfig {
  static const String appName = 'Gas Lagba - Vendor';
  static const String appVersion = '2.0.0';

  // API Configuration
  static const String apiBaseUrl = 'https://gaslagbaadmin.gtgroup.cloud/api/v1';
  // Alternative for local development:
  // static const String apiBaseUrl = 'http://192.168.1.100/gas-delivery/api/v1';

  // Emergency Contact
  static const String emergencyPhone = '+8801644274016';
  static const String emergencyName = 'Mahbubur Rahman';
  static const String emergencyRole = 'Founder and CEO';

  // Subscription - prices and promo codes are fetched from API
  // No hardcoded values here

  // Business Types
  static const String businessTypeGas = 'gas';
  static const String businessTypeGrocery = 'grocery';
  static const String businessTypeMedical = 'medical';

  // Order Status
  static const String orderPending = 'pending';
  static const String orderAccepted = 'accepted';
  static const String orderDeclined = 'declined';
  static const String orderPreparing = 'preparing';
  static const String orderReady = 'ready';
  static const String orderDispatched = 'dispatched';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  // Payment Methods
  static const String paymentCOD = 'cod';
  static const String paymentBkash = 'bkash';
  static const String paymentOnline = 'online';

  // Pagination
  static const int pageSize = 20;

  // Image Upload
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];

  // Bangladesh Currency
  static const String currency = '৳';
  static const String currencyCode = 'BDT';

  // Phone Validation (Bangladesh)
  static const String phoneRegex = r'^(?:\+88|88)?(01[3-9]\d{8})$';

  // Demo Credentials (for testing)
  static const String demoVendorPhone = '+8801700000002';
  static const String demoVendorPassword = 'vendor123';
}
