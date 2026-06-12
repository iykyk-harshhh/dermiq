import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';

import 'package:dermiq/features/home/providers/health_score_provider.dart';
import 'package:dermiq/features/shop/providers/cart_provider.dart';
import 'package:dermiq/features/shop/data/shop_models.dart';
import 'package:dermiq/features/streak/data/streak_models.dart';
import 'package:dermiq/features/scan/presentation/screens/product_analysis_screen.dart';

// QA / regression tests for the Phase-2…6 business logic. Pure functions and
// value objects only — fast, deterministic, no widget pumping.
void main() {
  group('Health score', () {
    test('blends AM/PM/consistency/adherence into 0–100', () {
      final score = computeHealthScore();
      expect(score, inInclusiveRange(0, 100));
    });

    test('a single yellow day (AM only) scores 50', () {
      // routineHistory[0] = Today: amDone true, pmDone false → yellow.
      // am=1, pm=0, consistency=1, adherence(full)=0 → 0.3+0.2 = 0.50 → 50.
      expect(computeHealthScore(window: 1), 50);
    });
  });

  group('Reward milestones', () {
    test('use the production set', () {
      expect(rewardMilestones, [50, 100, 150, 200, 250, 300, 365]);
    });

    test('milestone names', () {
      expect(milestoneName(50), 'Fifty Day Force');
      expect(milestoneName(250), 'Radiance Royalty');
      expect(milestoneName(365), 'Year of Radiance');
    });
  });

  group('Streak reward progress (green days only)', () {
    StreakState state({required int current, required int greenDays}) =>
        StreakState(
          current: current,
          greenDays: greenDays,
          best: current,
          claimedMilestones: const [],
          rewards: const [],
        );

    test('next milestone is driven by green days, not the streak', () {
      // 43-day streak but only 43 green days → next reward at 50.
      final s = state(current: 43, greenDays: 43);
      expect(s.nextMilestone, 50);
      expect(s.prevMilestone, 0);
      expect(s.progressToNext, closeTo(43 / 50, 0.0001));
    });

    test('crossing a milestone advances to the next band', () {
      final s = state(current: 60, greenDays: 50);
      expect(s.prevMilestone, 50);
      expect(s.nextMilestone, 100);
      expect(s.progressToNext, closeTo(0, 0.0001));
    });
  });

  group('Reward coupons at checkout', () {
    RewardGift gift(String name, RewardStatus status) => RewardGift(
          id: 'g',
          name: name,
          type: 'Discount Code',
          milestoneDays: 50,
          claimedDate: DateTime(2026, 1, 1),
          expiryDate: DateTime(2026, 4, 1),
          status: status,
        );

    StreakState withRewards(List<RewardGift> rewards) => StreakState(
          current: 50,
          greenDays: 50,
          best: 50,
          claimedMilestones: const [50],
          rewards: rewards,
        );

    test('active discount gift becomes a usable coupon', () {
      final coupons = activeRewardCoupons(
          withRewards([gift('10% Off Skincare Products', RewardStatus.active)]));
      expect(coupons, hasLength(1));
      expect(coupons.first.code, 'REWARD10');
      expect(coupons.first.discountPct, 10);
    });

    test('redeemed/expired or non-discount gifts are ignored', () {
      final coupons = activeRewardCoupons(withRewards([
        gift('10% Off', RewardStatus.redeemed),
        gift('Exclusive DermIQ Badge', RewardStatus.active), // no %
      ]));
      expect(coupons, isEmpty);
    });

    test('null streak state yields no coupons', () {
      expect(activeRewardCoupons(null), isEmpty);
    });
  });

  group('Cart totals', () {
    ShopProduct product(double price) => ShopProduct(
          id: 'p',
          name: 'Test',
          brand: 'B',
          category: 'Skincare',
          subCategory: 'Serum',
          description: '',
          howToUse: '',
          price: price,
          originalPrice: price,
          rating: 4.5,
          reviewCount: 10,
          dermiqMatchScore: 80,
          accentColor: const Color(0xFF7C5CFF),
        );

    test('free delivery above ₹999, charged below', () {
      final big = CartState(items: [CartItem(product: product(1200))]);
      expect(big.deliveryCharge, 0);
      final small = CartState(items: [CartItem(product: product(500))]);
      expect(small.deliveryCharge, 99);
    });

    test('coupon discount and total', () {
      final cart = CartState(
        items: [CartItem(product: product(1000), quantity: 2)],
        appliedCoupon: const Coupon(code: 'DERM10', discountPct: 10),
      );
      expect(cart.subtotal, 2000);
      expect(cart.discountAmount, 200);
      expect(cart.deliveryCharge, 0);
      expect(cart.total, 1800);
      expect(cart.itemCount, 2);
    });
  });

  group('Product recommendation status', () {
    test('thresholds map to the right labels', () {
      expect(recommendationFor(92).label, 'Highly Recommended');
      expect(recommendationFor(78).label, 'Recommended');
      expect(recommendationFor(55).label, 'Neutral');
      expect(recommendationFor(20).label, 'Not Recommended');
    });
  });
}
