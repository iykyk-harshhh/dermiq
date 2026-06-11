import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/streak_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Keys
// ─────────────────────────────────────────────────────────────────────────────

const _kCurrent = 'streak_current';
const _kBest = 'streak_best';
const _kLastDate = 'streak_last_date';
const _kLastAmDone = 'streak_last_am';
const _kLastPmDone = 'streak_last_pm';
const _kClaimed = 'streak_claimed_milestones';
const _kRewards = 'streak_rewards';

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class StreakNotifier extends AsyncNotifier<StreakState> {
  late SharedPreferences _prefs;

  @override
  Future<StreakState> build() async {
    _prefs = await SharedPreferences.getInstance();
    return _load();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<StreakState> _load() async {
    final now = _today();

    // Pre-seed 43-day streak on first run so the UI is populated immediately.
    final isFirstRun = !_prefs.containsKey(_kCurrent);
    if (isFirstRun) {
      final yesterday = now.subtract(const Duration(days: 1));
      await _prefs.setInt(_kCurrent, 43);
      await _prefs.setInt(_kBest, 43);
      await _prefs.setString(_kLastDate, yesterday.toIso8601String());
      await _prefs.setBool(_kLastAmDone, true);
      await _prefs.setBool(_kLastPmDone, true);
    }

    var current = _prefs.getInt(_kCurrent) ?? 0;
    final best = _prefs.getInt(_kBest) ?? 0;
    final lastDateStr = _prefs.getString(_kLastDate);
    final claimedRaw = _prefs.getString(_kClaimed);
    final rewardsRaw = _prefs.getString(_kRewards);

    final claimed = claimedRaw != null
        ? (jsonDecode(claimedRaw) as List<dynamic>).map((e) => e as int).toList()
        : <int>[];
    final rewards = rewardsRaw != null ? RewardGift.listFromJson(rewardsRaw) : <RewardGift>[];

    // Check if streak should break (missed yesterday).
    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);
      final diff = now.difference(lastDate).inDays;
      if (diff >= 2) {
        // Gap of 2+ days means we missed at least one full day.
        current = 0;
        await _prefs.setInt(_kCurrent, 0);
        // Trigger streak-broken notification.
        _onStreakBroken();
      }
    }

    return StreakState(
      current: current,
      best: best,
      claimedMilestones: claimed,
      rewards: _refreshExpiry(rewards),
    );
  }

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  String _uid() => DateTime.now().millisecondsSinceEpoch.toString();

  List<RewardGift> _refreshExpiry(List<RewardGift> rewards) {
    final now = DateTime.now();
    return rewards.map((r) {
      if (r.status == RewardStatus.active && r.expiryDate.isBefore(now)) {
        _onRewardExpired(r);
        return r.copyWith(status: RewardStatus.expired);
      }
      return r;
    }).toList();
  }

  // ── Notification stubs (ready for FCM wiring) ──────────────────────────────

  void _onStreakBroken() {
    // FCM / local notification hook — wired at the UI layer via pendingMilestone.
  }

  void _onRewardUnlocked(int milestone) {
    // FCM / local notification hook.
  }

  void _onRewardExpired(RewardGift gift) {
    // FCM / local notification hook.
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Called when the user completes AM or PM routine for today.
  Future<void> recordDayActivity({
    required bool amDone,
    required bool pmDone,
  }) async {
    final s = state.valueOrNull;
    if (s == null) return;

    final now = _today();
    final lastDateStr = _prefs.getString(_kLastDate);
    final lastDate =
        lastDateStr != null ? DateTime.parse(lastDateStr) : now.subtract(const Duration(days: 1));

    // Only advance streak once per calendar day.
    final alreadyRecordedToday = lastDate.isAtSameMomentAs(now);
    final prevAmDone = _prefs.getBool(_kLastAmDone) ?? false;
    final prevPmDone = _prefs.getBool(_kLastPmDone) ?? false;
    final wasAnyDone = prevAmDone || prevPmDone;
    final isAnyDone = amDone || pmDone;

    if (alreadyRecordedToday) {
      // Update today's completion but don't increment streak again.
      await _prefs.setBool(_kLastAmDone, amDone);
      await _prefs.setBool(_kLastPmDone, pmDone);
      // If went from nothing → something, increment streak.
      if (!wasAnyDone && isAnyDone) {
        await _incrementStreak(s, now);
      }
      return;
    }

    // New day.
    await _prefs.setString(_kLastDate, now.toIso8601String());
    await _prefs.setBool(_kLastAmDone, amDone);
    await _prefs.setBool(_kLastPmDone, pmDone);

    if (isAnyDone) {
      await _incrementStreak(s, now);
    } else {
      // Missed day → break streak.
      await _prefs.setInt(_kCurrent, 0);
      _onStreakBroken();
      state = AsyncData(s.copyWith(current: 0));
    }
  }

  Future<void> _incrementStreak(StreakState s, DateTime now) async {
    final newCurrent = s.current + 1;
    final newBest = newCurrent > s.best ? newCurrent : s.best;
    await _prefs.setInt(_kCurrent, newCurrent);
    await _prefs.setInt(_kBest, newBest);

    // Check for newly reached milestone.
    final hitMilestone = rewardMilestones
        .where((m) => m <= newCurrent && !s.claimedMilestones.contains(m))
        .lastOrNull;

    if (hitMilestone != null) {
      _onRewardUnlocked(hitMilestone);
    }

    state = AsyncData(s.copyWith(
      current: newCurrent,
      best: newBest,
      pendingMilestone: hitMilestone,
    ));
  }

  /// User selected a reward option for the [milestone] — store the gift.
  Future<void> claimReward(int milestone, RewardOption option) async {
    final s = state.valueOrNull;
    if (s == null) return;

    final now = DateTime.now();
    final gift = RewardGift(
      id: _uid(),
      name: option.name,
      type: option.type,
      milestoneDays: milestone,
      claimedDate: now,
      expiryDate: now.add(const Duration(days: 90)),
      status: RewardStatus.active,
    );

    final newRewards = [...s.rewards, gift];
    final newClaimed = [...s.claimedMilestones, milestone];

    await _prefs.setString(_kRewards, RewardGift.listToJson(newRewards));
    await _prefs.setString(_kClaimed, jsonEncode(newClaimed));

    state = AsyncData(s.copyWith(
      rewards: newRewards,
      claimedMilestones: newClaimed,
      clearPending: true,
    ));
  }

  /// Dismiss the pending milestone without claiming (rare — skip).
  Future<void> dismissPendingMilestone() async {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(clearPending: true));
  }

  /// Mark a reward as redeemed.
  Future<void> redeemReward(String rewardId) async {
    final s = state.valueOrNull;
    if (s == null) return;
    final updated = s.rewards
        .map((r) => r.id == rewardId ? r.copyWith(status: RewardStatus.redeemed) : r)
        .toList();
    await _prefs.setString(_kRewards, RewardGift.listToJson(updated));
    state = AsyncData(s.copyWith(rewards: updated));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final streakProvider =
    AsyncNotifierProvider<StreakNotifier, StreakState>(StreakNotifier.new);
