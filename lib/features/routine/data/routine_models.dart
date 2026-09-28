import 'package:flutter/material.dart';

class RoutineStep {
  final String id;
  final String stepType;
  final String productName;
  final String description;
  final String tip;
  final IconData icon;
  final Color color;
  final int durationMin;

  const RoutineStep({
    required this.id,
    required this.stepType,
    required this.productName,
    required this.description,
    required this.tip,
    required this.icon,
    required this.color,
    required this.durationMin,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'stepType': stepType,
        'productName': productName,
        'description': description,
        'tip': tip,
        'iconCodePoint': icon.codePoint,
        'iconFontFamily': icon.fontFamily,
        'iconFontPackage': icon.fontPackage,
        'color': color.toARGB32(),
        'durationMin': durationMin,
      };

  factory RoutineStep.fromMap(Map<String, dynamic> m) => RoutineStep(
        id: m['id'] as String? ?? '',
        stepType: m['stepType'] as String? ?? '',
        productName: m['productName'] as String? ?? '',
        description: m['description'] as String? ?? '',
        tip: m['tip'] as String? ?? '',
        icon: _iconFor((m['iconCodePoint'] as num?)?.toInt()),
        color: Color((m['color'] as num?)?.toInt() ?? 0xFF7C5CFF),
        durationMin: (m['durationMin'] as num?)?.toInt() ?? 1,
      );

  /// Resolves a persisted icon codePoint back to a *const* [IconData] so the
  /// icon tree-shaker stays happy (dynamic `IconData(...)` is disallowed).
  /// Covers every icon the seed routines and the builder's step picker use.
  static IconData _iconFor(int? codePoint) {
    const known = <IconData>[
      Icons.water_drop_rounded,
      Icons.science_rounded,
      Icons.biotech_rounded,
      Icons.spa_rounded,
      Icons.wb_sunny_rounded,
      Icons.cleaning_services_rounded,
      Icons.auto_awesome_rounded,
      Icons.blur_on_rounded,
      Icons.remove_red_eye_rounded,
      Icons.face_retouching_natural_rounded,
    ];
    for (final i in known) {
      if (i.codePoint == codePoint) return i;
    }
    return Icons.spa_rounded;
  }
}

class RoutineDay {
  final String label;
  final bool amDone;
  final bool pmDone;
  final int score;

  /// `yyyy-mm-dd` key for the day this entry represents. Nullable for legacy
  /// entries (labels-only) and lets the notifier relabel entries over time.
  final String? dateKey;

  const RoutineDay(this.label, this.amDone, this.pmDone, this.score,
      {this.dateKey});

  bool get anyDone => amDone || pmDone;
  bool get fullDone => amDone && pmDone;

  Map<String, dynamic> toMap() => {
        'label': label,
        'amDone': amDone,
        'pmDone': pmDone,
        'score': score,
        if (dateKey != null) 'dateKey': dateKey,
      };

  factory RoutineDay.fromMap(Map<String, dynamic> m) => RoutineDay(
        m['label'] as String? ?? '',
        m['amDone'] as bool? ?? false,
        m['pmDone'] as bool? ?? false,
        (m['score'] as num?)?.toInt() ?? 0,
        dateKey: m['dateKey'] as String?,
      );
}

// ── AM Steps ──────────────────────────────────────────────────────────────────

const amSteps = [
  RoutineStep(
    id: 'am1', stepType: 'Cleanse',
    productName: 'Hydra-Boost Cleanser',
    description: 'Removes overnight buildup gently',
    tip: 'Use lukewarm water — hot water strips the skin barrier',
    icon: Icons.water_drop_rounded, color: Color(0xFF06B6D4), durationMin: 2,
  ),
  RoutineStep(
    id: 'am2', stepType: 'Tone',
    productName: 'Glycolic Toner 7%',
    description: 'Balances pH and preps skin for actives',
    tip: 'Apply with a cotton pad in gentle upward strokes',
    icon: Icons.science_rounded, color: Color(0xFF8B5CF6), durationMin: 1,
  ),
  RoutineStep(
    id: 'am3', stepType: 'Treat',
    productName: 'Niacinamide 10% Serum',
    description: 'Brightens and controls sebum production',
    tip: 'A few drops covers the whole face — warm between palms first',
    icon: Icons.biotech_rounded, color: Color(0xFF7C5CFF), durationMin: 2,
  ),
  RoutineStep(
    id: 'am4', stepType: 'Moisturize',
    productName: 'Moisture Surge 72H',
    description: 'Long-lasting all-day hydration',
    tip: 'Apply to slightly damp skin for better absorption',
    icon: Icons.spa_rounded, color: Color(0xFF22C55E), durationMin: 1,
  ),
  RoutineStep(
    id: 'am5', stepType: 'Protect',
    productName: 'Ultra Defense SPF 50+',
    description: 'Broad-spectrum UV shield',
    tip: 'Apply generously — most people use too little',
    icon: Icons.wb_sunny_rounded, color: Color(0xFFF59E0B), durationMin: 1,
  ),
];

// ── PM Steps ──────────────────────────────────────────────────────────────────

const pmSteps = [
  RoutineStep(
    id: 'pm1', stepType: 'Oil Cleanse',
    productName: 'Cleansing Balm',
    description: 'Melts away sunscreen and makeup',
    tip: 'Massage 60 seconds on dry skin before adding water',
    icon: Icons.cleaning_services_rounded, color: Color(0xFFEC4899), durationMin: 2,
  ),
  RoutineStep(
    id: 'pm2', stepType: 'Cleanse',
    productName: 'Hydra-Boost Cleanser',
    description: 'Second cleanse for a thorough clean',
    tip: 'Rinse with cool water to soothe and close pores',
    icon: Icons.water_drop_rounded, color: Color(0xFF06B6D4), durationMin: 1,
  ),
  RoutineStep(
    id: 'pm3', stepType: 'Treat',
    productName: 'Retinol 0.5% Serum',
    description: 'Overnight cell renewal hero',
    tip: 'Start 2–3 nights per week then build up slowly',
    icon: Icons.auto_awesome_rounded, color: Color(0xFF8B5CF6), durationMin: 2,
  ),
  RoutineStep(
    id: 'pm4', stepType: 'Moisturize',
    productName: 'Barrier Repair Cream',
    description: 'Rich overnight recovery formula',
    tip: 'Apply generously — this seals in all your actives',
    icon: Icons.spa_rounded, color: Color(0xFF22C55E), durationMin: 1,
  ),
];

// ── History (14 days, index 0 = today) ───────────────────────────────────────

const routineHistory = [
  RoutineDay('Today',     true,  false, 82),
  RoutineDay('Yesterday', true,  true,  90),
  RoutineDay('Monday',    true,  true,  88),
  RoutineDay('Sunday',    false, true,  75),
  RoutineDay('Saturday',  true,  true,  91),
  RoutineDay('Friday',    true,  false, 80),
  RoutineDay('Thursday',  true,  true,  85),
  RoutineDay('Wednesday', false, false, 50),
  RoutineDay('Tuesday',   true,  true,  88),
  RoutineDay('Monday',    true,  false, 78),
  RoutineDay('Sunday',    true,  true,  89),
  RoutineDay('Saturday',  true,  true,  92),
  RoutineDay('Friday',    false, true,  72),
  RoutineDay('Thursday',  true,  true,  86),
];
