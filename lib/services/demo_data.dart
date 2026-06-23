import '../models/vendor.dart';
import '../models/vendor_status.dart';

/// Demo data provider for offline testing without backend server
class DemoData {
  // Demo vendor account
  static final Vendor demoVendor = Vendor(
    id: 1,
    uniqueId: 'V12345678',
    name: 'Demo Vendor',
    fatherName: 'Demo Father',
    village: 'Dhaka',
    houseName: 'House 123',
    mobile: '+8801700000002',
    businessName: 'Gas Cylinder Shop',
    businessType: 'gas',
    status: VendorStatus.approved,
    isVerified: true,
    isApproved: true,
    subscriptionStatus: 'active',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  // Demo auth token
  static const String demoToken = 'demo_auth_token_12345';

  // Demo vendor credentials
  static const String demoPhone = '+8801700000002';
  static const String demoPassword = 'vendor123';

  // Check if credentials match demo account
  static bool isValidDemoCredentials(String mobile, String password) {
    return mobile == demoPhone && password == demoPassword;
  }

  // Simulate login response
  static Map<String, dynamic> getDemoLoginResponse() {
    return {
      'success': true,
      'message': 'Login successful (Demo Mode)',
      'token': demoToken,
      'vendor': demoVendor.toJson(),
    };
  }

  // Dashboard statistics
  static Map<String, dynamic> getDemoDashboardStats() {
    return {
      'total_orders': 45,
      'pending_orders': 5,
      'completed_orders': 38,
      'cancelled_orders': 2,
      'today_orders': 8,
      'today_sales': 12500.0,
      'this_month_sales': 125000.0,
      'total_sales': 450000.0,
    };
  }

  // Recent orders
  static List<Map<String, dynamic>> getDemoOrders() {
    return [
      {
        'id': '1',
        'order_number': 'ORD-001',
        'customer_name': 'John Doe',
        'customer_phone': '+8801700000001',
        'customer_address': 'House 45, Gulshan, Dhaka',
        'total_amount': 1500.0,
        'status': 'pending',
        'payment_method': 'cod',
        'created_at': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        'items': [
          {
            'product_name': '12 KG Gas Cylinder',
            'quantity': 1,
            'price': 1500.0,
          },
        ],
      },
      {
        'id': '2',
        'order_number': 'ORD-002',
        'customer_name': 'Jane Smith',
        'customer_phone': '+8801700000003',
        'customer_address': 'House 78, Banani, Dhaka',
        'total_amount': 3000.0,
        'status': 'accepted',
        'payment_method': 'bkash',
        'created_at': DateTime.now()
            .subtract(const Duration(hours: 5))
            .toIso8601String(),
        'items': [
          {
            'product_name': '12 KG Gas Cylinder',
            'quantity': 2,
            'price': 3000.0,
          },
        ],
      },
      {
        'id': '3',
        'order_number': 'ORD-003',
        'customer_name': 'Ahmed Rahman',
        'customer_phone': '+8801700000004',
        'customer_address': 'House 12, Dhanmondi, Dhaka',
        'total_amount': 750.0,
        'status': 'delivered',
        'payment_method': 'cod',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        'delivered_at': DateTime.now()
            .subtract(const Duration(hours: 18))
            .toIso8601String(),
        'items': [
          {'product_name': '5 KG Gas Cylinder', 'quantity': 1, 'price': 750.0},
        ],
      },
    ];
  }
}
