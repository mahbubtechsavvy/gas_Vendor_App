import '../config/app_config.dart';

class ApiEndpoints {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Auth (Email OTP)
  static String get requestOtp => '$baseUrl/auth/otp/request';
  static String get verifyOtp => '$baseUrl/auth/otp/verify';

  // Vendor Profile & Registration
  static String get vendorProfile => '$baseUrl/vendor';
  static String get vendorRegister => '$baseUrl/vendor/register';

  // Branches
  static String get branches => '$baseUrl/vendor/branches';
  static String branch(String id) => '$baseUrl/vendor/branches/$id';
  static String openBranch(String id) => '$baseUrl/vendor/branches/$id/open';
  static String closeBranch(String id) => '$baseUrl/vendor/branches/$id/close';
  static String deliveryHours(String id) => '$baseUrl/vendor/branches/$id/delivery-hours';
  static String coverage(String id) => '$baseUrl/vendor/branches/$id/coverage';

  // Staff (Owner only)
  static String get staff => '$baseUrl/vendor/staff';
  static String staffMember(String id) => '$baseUrl/vendor/staff/$id';

  // Inventory
  static String branchInventory(String branchId) => '$baseUrl/vendor/branches/$branchId/inventory';
  static String adjustInventory(String branchId) => '$baseUrl/vendor/branches/$branchId/inventory/adjust';
  static String inventoryMovements(String branchId) => '$baseUrl/vendor/branches/$branchId/inventory/movements';

  // Orders & State Machine
  static String get orders => '$baseUrl/vendor/orders';
  static String order(String id) => '$baseUrl/vendor/orders/$id';
  static String acceptOrder(String id) => '$baseUrl/vendor/orders/$id/accept';
  static String preparingOrder(String id) => '$baseUrl/vendor/orders/$id/preparing';
  static String readyOrder(String id) => '$baseUrl/vendor/orders/$id/ready';
  static String dispatchOrder(String id) => '$baseUrl/vendor/orders/$id/dispatch';
  static String deliverOrder(String id) => '$baseUrl/vendor/orders/$id/delivered';
  static String rejectOrder(String id) => '$baseUrl/vendor/orders/$id/reject';
  static String decideCancellation(String id) => '$baseUrl/vendor/orders/$id/cancellation-request/decide';

  // Riders & Deliveries
  static String get riders => '$baseUrl/vendor/riders';
  static String rider(String id) => '$baseUrl/vendor/riders/$id';
  static String get assignDelivery => '$baseUrl/vendor/deliveries/assign';
  static String updateDelivery(String orderId) => '$baseUrl/vendor/orders/$orderId/delivery';

  // Payouts & Ledger
  static String get payoutBalance => '$baseUrl/vendor/payouts/balance';
  static String get payoutLedger => '$baseUrl/vendor/payouts/ledger';
  static String get requestPayout => '$baseUrl/vendor/payouts/request';

  // Subscriptions
  static String get subscriptionPlans => '$baseUrl/subscriptions/plans';
  static String get vendorSubscription => '$baseUrl/subscriptions/vendor/current';
  static String get choosePlan => '$baseUrl/subscriptions/vendor';
  static String submitSubscriptionPayment(String subscriptionId) => '$baseUrl/subscriptions/vendor/$subscriptionId/payments';

  // Notifications & Device Tokens
  static String get notifications => '$baseUrl/me/notifications';
  static String markNotificationRead(String id) => '$baseUrl/me/notifications/$id/read';
  static String get markAllNotificationsRead => '$baseUrl/me/notifications/read-all';
  static String get devices => '$baseUrl/devices';
}
