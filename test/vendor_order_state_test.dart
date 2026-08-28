import 'package:flutter_test/flutter_test.dart';
import 'package:vendorapp/models/vendor_order_model.dart';

void main() {
  group('Vendor Order Status & State Machine Tests', () {
    test('Maps string status properly', () {
      expect(VendorOrderStatus.fromString('PENDING'), VendorOrderStatus.pending);
      expect(VendorOrderStatus.fromString('ACCEPTED'), VendorOrderStatus.accepted);
      expect(VendorOrderStatus.fromString('PREPARING'), VendorOrderStatus.preparing);
      expect(VendorOrderStatus.fromString('READY'), VendorOrderStatus.ready);
      expect(VendorOrderStatus.fromString('OUT_FOR_DELIVERY'), VendorOrderStatus.outForDelivery);
      expect(VendorOrderStatus.fromString('DELIVERED'), VendorOrderStatus.delivered);
      expect(VendorOrderStatus.fromString('CANCELLED'), VendorOrderStatus.cancelled);
      expect(VendorOrderStatus.fromString('REJECTED'), VendorOrderStatus.rejected);
      expect(VendorOrderStatus.fromString('UNKNOWN'), VendorOrderStatus.pending);
    });

    test('Identifies active vs terminal states accurately', () {
      expect(VendorOrderStatus.pending.isActive, isTrue);
      expect(VendorOrderStatus.accepted.isActive, isTrue);
      expect(VendorOrderStatus.preparing.isActive, isTrue);
      expect(VendorOrderStatus.ready.isActive, isTrue);
      expect(VendorOrderStatus.outForDelivery.isActive, isTrue);

      expect(VendorOrderStatus.delivered.isActive, isFalse);
      expect(VendorOrderStatus.delivered.isTerminal, isTrue);
      expect(VendorOrderStatus.cancelled.isTerminal, isTrue);
      expect(VendorOrderStatus.rejected.isTerminal, isTrue);
    });

    test('Parses order model JSON correctly with integer Paisa money', () {
      final json = {
        'id': 'ord-123',
        'orderNumber': 'GL-20260828-000001',
        'status': 'PENDING',
        'subtotalPaisa': 145000,
        'depositTotalPaisa': 50000,
        'deliveryFeePaisa': 6000,
        'totalPaisa': 201000,
        'customer': {
          'fullName': 'Rahim Uddin',
          'phone': '+8801711111111',
        },
        'deliveryAddressText': 'House 12, Road 5, Dhanmondi, Dhaka',
        'deliveryMode': 'ASAP',
        'paymentMethod': 'COD',
        'items': [
          {
            'id': 'item-1',
            'productName': 'Beximco LPG 12kg',
            'variantName': 'Refill',
            'quantity': 1,
            'unitPricePaisa': 145000,
            'depositPaisa': 50000,
            'lineTotalPaisa': 195000,
          }
        ],
        'createdAt': '2026-08-28T10:00:00.000Z',
      };

      final order = VendorOrderModel.fromJson(json);

      expect(order.id, 'ord-123');
      expect(order.orderNumber, 'GL-20260828-000001');
      expect(order.status, VendorOrderStatus.pending);
      expect(order.customerName, 'Rahim Uddin');
      expect(order.subtotal.paisa, 145000);
      expect(order.depositTotal.paisa, 50000);
      expect(order.deliveryFee.paisa, 6000);
      expect(order.total.paisa, 201000);
      expect(order.items.length, 1);
      expect(order.items.first.productName, 'Beximco LPG 12kg');
    });
  });
}
