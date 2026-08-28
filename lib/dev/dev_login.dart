/// DEV-LOGIN-BACKDOOR — TEMPORARY. Delete this file once the backend is complete; the
/// removal checklist lives in gas-lagba-api/docs/06-security/DEV_LOGIN_BACKDOOR.md.
///
/// A one-tap way past the login screen so the UI can be exercised while the backend is
/// still being built. It fabricates a local session only — no network call, no real
/// token — so authenticated screens will still fail against a live API. That is the
/// point: this unlocks navigation and layout work, not end-to-end testing.
///
/// [kDebugMode] is the lock. Release and profile builds compile the button and this
/// session away entirely, so a shipped APK cannot contain the backdoor even if someone
/// forgets to remove the code.
library;

import 'package:flutter/foundation.dart';

import '../models/vendor.dart';
import '../models/vendor_status.dart';

class DevLogin {
  const DevLogin._();

  /// Off in release/profile builds, always. Debug builds can still opt out with
  /// `flutter run --dart-define=DEV_LOGIN=false`.
  static bool get enabled => kDebugMode && const bool.fromEnvironment('DEV_LOGIN', defaultValue: true);

  /// Deliberately not token-shaped, so it is obvious in a log that it is not a real one.
  static const String token = 'dev-login-placeholder-not-a-real-token';

  /// Approved and subscribed, so the dashboard and the gated screens are all reachable.
  static Vendor vendor() => Vendor(
    id: 0,
    uniqueId: 'VDEV0000',
    name: 'Dev Vendor (backdoor)',
    fatherName: 'Dev',
    village: 'Dhaka',
    houseName: 'Dev House',
    mobile: '+8800000000000',
    // Reserved `.local` TLD (RFC 6762): this address can never receive mail.
    email: 'dev-vendor@gaslagba.local',
    shopAddress: 'Dev Shop, Dhaka',
    businessName: 'Dev Gas Shop',
    businessType: 'gas',
    isVerified: true,
    isApproved: true,
    subscriptionStatus: 'active',
    status: VendorStatus.approved,
    createdAt: DateTime.now(),
  );
}
