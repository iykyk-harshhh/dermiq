import 'dart:convert';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum StreakDayStatus { full, partial, missed, future }

enum RewardStatus { active, redeemed, expired }

// ─────────────────────────────────────────────────────────────────────────────
// Reward options presented at each milestone
// ─────────────────────────────────────────────────────────────────────────────

class RewardOption {
  final String name;
  final String type;
  final String description;
  final String emoji;

  const RewardOption({
    required this.name,
    required this.type,
    required this.description,
    required this.emoji,
  });
}

const rewardOptions = <RewardOption>[
  RewardOption(
    name: '10% Off Skincare Products',
    type: 'Discount Code',
    description: 'One-time 10% discount on any DermIQ partner product order.',
    emoji: '🏷️',
  ),
  RewardOption(
    name: 'Free 15-min Consultation',
    type: 'Premium Feature',
    description: 'A complimentary 15-minute video call with a DermIQ specialist.',
    emoji: '🩺',
  ),
  RewardOption(
    name: 'Complimentary Product Sample',
    type: 'Free Sample',
    description: 'Receive a curated product sample matched to your skin profile.',
    emoji: '🎁',
  ),
  RewardOption(
    name: 'Exclusive DermIQ Badge',
    type: 'Digital Badge',
    description: 'A unique profile badge celebrating your dedication.',
    emoji: '🏅',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Milestone definitions
// ─────────────────────────────────────────────────────────────────────────────

const rewardMilestones = <int>[7, 30, 50, 100, 150, 200, 365];

String milestoneName(int days) {
  switch (days) {
    case 7:   return 'One Week Warrior';
    case 30:  return 'Monthly Master';
    case 50:  return 'Fifty Day Force';
    case 100: return 'Century Champion';
    case 150: return 'Glow Legend';
    case 200: return 'Skin Immortal';
    case 365: return 'Year of Radiance';
    default:  return '$days Day Streak';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stored reward gift
// ─────────────────────────────────────────────────────────────────────────────

class RewardGift {
  final String id;
  final String name;
  final String type;
  final int milestoneDays;
  final DateTime claimedDate;
  final DateTime expiryDate;
  final RewardStatus status;

  const RewardGift({
    required this.id,
    required this.name,
    required this.type,
    required this.milestoneDays,
    required this.claimedDate,
    required this.expiryDate,
    required this.status,
  });

  RewardGift copyWith({RewardStatus? status}) => RewardGift(
        id: id,
        name: name,
        type: type,
        milestoneDays: milestoneDays,
        claimedDate: claimedDate,
        expiryDate: expiryDate,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'milestoneDays': milestoneDays,
        'claimedDate': claimedDate.toIso8601String(),
        'expiryDate': expiryDate.toIso8601String(),
        'status': status.name,
      };

  factory RewardGift.fromJson(Map<String, dynamic> j) => RewardGift(
        id: j['id'] as String,
        name: j['name'] as String,
        type: j['type'] as String,
        milestoneDays: j['milestoneDays'] as int,
        claimedDate: DateTime.parse(j['claimedDate'] as String),
        expiryDate: DateTime.parse(j['expiryDate'] as String),
        status: RewardStatus.values.firstWhere((s) => s.name == j['status']),
      );

  static List<RewardGift> listFromJson(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => RewardGift.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<RewardGift> gifts) =>
      jsonEncode(gifts.map((g) => g.toJson()).toList());
}

// ─────────────────────────────────────────────────────────────────────────────
// Streak state snapshot
// ─────────────────────────────────────────────────────────────────────────────

class StreakState {
  final int current;
  final int best;
  final List<int> claimedMilestones;
  final List<RewardGift> rewards;

  /// Non-null when the user just crossed a milestone and hasn't chosen a reward yet.
  final int? pendingMilestone;

  const StreakState({
    required this.current,
    required this.best,
    required this.claimedMilestones,
    required this.rewards,
    this.pendingMilestone,
  });

  StreakState copyWith({
    int? current,
    int? best,
    List<int>? claimedMilestones,
    List<RewardGift>? rewards,
    int? pendingMilestone,
    bool clearPending = false,
  }) =>
      StreakState(
        current: current ?? this.current,
        best: best ?? this.best,
        claimedMilestones: claimedMilestones ?? this.claimedMilestones,
        rewards: rewards ?? this.rewards,
        pendingMilestone: clearPending ? null : (pendingMilestone ?? this.pendingMilestone),
      );

  int get nextMilestone =>
      rewardMilestones.firstWhere((m) => m > current, orElse: () => current + 50);

  int get prevMilestone {
    final passed = rewardMilestones.where((m) => m <= current).toList();
    return passed.isEmpty ? 0 : passed.last;
  }

  double get progressToNext {
    final span = (nextMilestone - prevMilestone).clamp(1, 9999);
    return ((current - prevMilestone) / span).clamp(0.0, 1.0);
  }
}
