import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentOutcome { success, failed, cancelled }

class PaymentResult {
  final PaymentOutcome outcome;
  final String? paymentId;
  final String? message;
  const PaymentResult(this.outcome, {this.paymentId, this.message});

  bool get isSuccess => outcome == PaymentOutcome.success;
}

/// Checkout runs in **demo mode**: online payments are simulated (no real
/// charge, no backend). This is a portfolio build kept on Firebase's free tier
/// — real Razorpay checkout would need a paid Blaze plan (Cloud Functions) plus
/// a merchant account, so it is intentionally left out.
class PaymentService {
  const PaymentService();

  Future<PaymentResult> payForOrder({
    required int amountPaise,
    required String receipt,
    required String name,
    required String email,
    required String phone,
    String description = 'DermIQ order',
  }) async {
    // Simulate a payment round-trip, then report success.
    await Future.delayed(const Duration(milliseconds: 1400));
    return PaymentResult(
      PaymentOutcome.success,
      paymentId: 'demo_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

final paymentServiceProvider =
    Provider<PaymentService>((ref) => const PaymentService());
