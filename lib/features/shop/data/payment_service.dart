import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentOutcome { success, failed, cancelled }

class PaymentResult {
  final PaymentOutcome outcome;
  final String? paymentId;
  final String? message;
  const PaymentResult(this.outcome, {this.paymentId, this.message});

  bool get isSuccess => outcome == PaymentOutcome.success;
}

/// Online payments (Razorpay) are a **post-investment** feature. The secure
/// server side already exists (`functions/index.js`: `createRazorpayOrder` +
/// `verifyRazorpayPayment`); only the native `razorpay_flutter` checkout sheet
/// is decoupled from the pitch build (AGP-8 namespace conflict + needs a
/// merchant account). Until it's re-added, `payForOrder` reports "unavailable"
/// so checkout falls back to Cash on Delivery.
///
/// To re-enable after funding:
///   1. Uncomment `razorpay_flutter` in pubspec.yaml + resolve the AGP namespace
///      conflict, `flutter pub get`.
///   2. Restore the Razorpay checkout flow here (create order → open sheet →
///      verify signature via the existing Cloud Functions). See git history.
class PaymentService {
  PaymentService(this._functions);
  // ignore: unused_field — kept for the post-investment Razorpay flow.
  final FirebaseFunctions _functions;

  Future<PaymentResult> payForOrder({
    required int amountPaise,
    required String receipt,
    required String name,
    required String email,
    required String phone,
    String description = 'DermIQ order',
  }) async {
    return const PaymentResult(
      PaymentOutcome.failed,
      message: 'Online payment isn\'t enabled yet — please choose Cash on Delivery.',
    );
  }
}

final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instanceFor(region: 'us-central1');
});

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(ref.watch(firebaseFunctionsProvider));
});
