import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';

// ── Specialist ────────────────────────────────────────────────────────────────

class Specialist {
  final String id;
  final String name;
  final String type; // Dermatologist / Trichologist / Cosmetologist
  final String qualifications;
  final double rating;
  final int reviews;
  final int yearsExp;
  final Color color;
  final double fee; // consultation fee (USD)
  final String hospital;
  final String address;
  final double distanceKm;
  final String about;
  final List<String> specialties;
  final List<String> slots;
  final bool offersOnline;   // video/chat consultations
  final bool offersInPerson; // physical clinic visits

  const Specialist({
    required this.id,
    required this.name,
    required this.type,
    required this.qualifications,
    required this.rating,
    required this.reviews,
    required this.yearsExp,
    required this.color,
    required this.fee,
    required this.hospital,
    required this.address,
    required this.distanceKm,
    required this.about,
    required this.specialties,
    required this.slots,
    this.offersOnline = true,
    this.offersInPerson = true,
  });

  /// Rating to one decimal: `4.9`.
  String get ratingStr => Fmt.rating(rating);

  /// Two-letter initials derived from the name (skips a leading "Dr.").
  /// Hardened against short/empty names so it can never throw a RangeError.
  String get initials {
    final clean = name.replaceFirst('Dr. ', '').trim();
    final parts = clean.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (clean.isEmpty) return '?';
    return clean.padRight(2, ' ').substring(0, 2).trim().toUpperCase();
  }
}

const specialistMocks = <Specialist>[
  Specialist(
    id: 's1',
    name: 'Dr. Sarah Chen',
    type: 'Dermatologist',
    qualifications: 'MBBS, MD (Dermatology)',
    rating: 4.9,
    reviews: 218,
    yearsExp: 12,
    color: Color(0xFF8B6FE8),
    fee: 80,
    hospital: 'City Skin & Laser Clinic',
    address: '14 Maple Ave, Suite 3, Downtown',
    distanceKm: 1.2,
    about:
        'Dr. Sarah Chen is a board-certified dermatologist with over 12 years of experience treating acne, hyperpigmentation, and aging concerns. She combines evidence-based treatments with advanced technology for personalised care.',
    specialties: ['Acne', 'Hyperpigmentation', 'Anti-aging', 'Rosacea', 'Chemical Peels'],
    slots: ['10:00 AM', '11:30 AM', '2:00 PM', '3:30 PM', '5:00 PM'],
  ),
  Specialist(
    id: 's2',
    name: 'Dr. Priya Sharma',
    type: 'Trichologist',
    qualifications: 'MD, Trichology Cert.',
    rating: 4.8,
    reviews: 165,
    yearsExp: 9,
    color: Color(0xFF7C5CFF),
    fee: 70,
    hospital: 'HairCare Wellness Centre',
    address: '7 Oak Street, Midtown',
    distanceKm: 2.5,
    about:
        'Dr. Priya Sharma specialises in hair and scalp health, with deep expertise in hair-loss management, PRP therapy, and scalp conditions. She has helped hundreds of patients restore healthy hair.',
    specialties: ['Hair Loss', 'Scalp Health', 'PRP Therapy', 'Dandruff', 'Hair Transplant'],
    slots: ['9:30 AM', '11:00 AM', '1:00 PM', '4:00 PM'],
  ),
  Specialist(
    id: 's3',
    name: 'Dr. James Wright',
    type: 'Dermatologist',
    qualifications: 'MBBS, FAAD',
    rating: 4.7,
    reviews: 312,
    yearsExp: 15,
    color: Color(0xFF6045CC),
    fee: 90,
    hospital: 'Westside Medical Centre',
    address: '22 Brook Lane, West End',
    distanceKm: 4.1,
    about:
        'Dr. James Wright is a fellowship-trained dermatologist focused on medical dermatology, including eczema, rosacea, and skin-cancer screening. He is known for thorough, patient-first consultations.',
    specialties: ['Eczema', 'Rosacea', 'Skin Cancer', 'Psoriasis', 'Mole Checks'],
    slots: ['9:00 AM', '10:30 AM', '12:00 PM', '2:30 PM', '4:30 PM'],
    offersOnline: false, // clinic visits only
  ),
  Specialist(
    id: 's4',
    name: 'Maya Patel',
    type: 'Cosmetologist',
    qualifications: 'Adv. Dip. Cosmetology',
    rating: 4.8,
    reviews: 97,
    yearsExp: 7,
    color: Color(0xFF9B7FEA),
    fee: 60,
    hospital: 'Glow Studio & Spa',
    address: '5 Rose Court, Northside',
    distanceKm: 0.8,
    about:
        'Maya Patel is a certified cosmetologist delivering results-driven facials, chemical peels, and microneedling. She tailors every treatment to your skin goals and lifestyle.',
    specialties: ['Facials', 'Chemical Peels', 'Microneedling', 'Brightening', 'Hydration'],
    slots: ['10:00 AM', '11:30 AM', '1:30 PM', '3:00 PM', '5:30 PM'],
    offersInPerson: false, // online consultations only
  ),
];

Specialist lookupSpecialist(String id) =>
    specialistMocks.firstWhere((s) => s.id == id, orElse: () => specialistMocks.first);

// ── Consultation type ─────────────────────────────────────────────────────────

const consultTypes = ['In-Person', 'Video Call', 'Chat'];

IconData consultIcon(String type) {
  switch (type) {
    case 'Video Call':
      return Icons.videocam_rounded;
    case 'Chat':
      return Icons.chat_bubble_rounded;
    case 'In-Person':
    default:
      return Icons.location_on_rounded;
  }
}

int consultDuration(String type) {
  switch (type) {
    case 'Video Call':
      return 30;
    case 'Chat':
      return 20;
    case 'In-Person':
    default:
      return 45;
  }
}

// ── Booking draft (passed booking → confirmation via GoRouter extra) ──────────

class BookingDraft {
  final String specialistId;
  final DateTime startAt; // real appointment date + slot time
  final String consultType;
  final int durationMin;
  final double fee;
  final String reason; // free-text "reason for visit" (may be empty)

  const BookingDraft({
    required this.specialistId,
    required this.startAt,
    required this.consultType,
    required this.durationMin,
    required this.fee,
    this.reason = '',
  });

  /// Human date label derived from [startAt] (e.g. 'Today, Jun 9').
  String get dateLabel => relativeDayLabel(startAt);

  /// Human time label derived from [startAt] (e.g. '2:00 PM').
  String get time => timeLabel(startAt);
}

// ── Appointment (My Appointments) ─────────────────────────────────────────────

enum AppointmentStatus { upcoming, completed, cancelled, missed }

class Appointment {
  final String id;
  final String specialistId;
  final DateTime startAt; // real date + time (source of truth)
  final String consultType;
  final int durationMin;
  final AppointmentStatus status;
  final String reason; // free-text "reason for visit" (may be empty)

  const Appointment({
    required this.id,
    required this.specialistId,
    required this.startAt,
    required this.consultType,
    required this.durationMin,
    required this.status,
    this.reason = '',
  });

  Specialist get specialist => lookupSpecialist(specialistId);

  /// Human date label derived from [startAt] (e.g. 'Tomorrow, Jun 10').
  String get dateLabel => relativeDayLabel(startAt);

  /// Human time label derived from [startAt] (e.g. '10:30 AM').
  String get time => timeLabel(startAt);

  /// End of the session, used for status derivation.
  DateTime get endAt => startAt.add(Duration(minutes: durationMin));

  /// Free client-side status derivation (no backend): an [upcoming]
  /// appointment whose session has already ended is treated as [completed].
  /// Terminal statuses (completed / cancelled / missed) are returned as-is.
  AppointmentStatus get effectiveStatus {
    if (status == AppointmentStatus.upcoming &&
        DateTime.now().isAfter(endAt)) {
      return AppointmentStatus.completed;
    }
    return status;
  }

  /// Returns this appointment with its status resolved to [effectiveStatus].
  Appointment resolved() => effectiveStatus == status
      ? this
      : copyWith(status: effectiveStatus);

  Appointment copyWith({AppointmentStatus? status}) => Appointment(
        id: id,
        specialistId: specialistId,
        startAt: startAt,
        consultType: consultType,
        durationMin: durationMin,
        status: status ?? this.status,
        reason: reason,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'specialistId': specialistId,
        // Real date/time — sortable, comparable, never goes stale.
        'startAt': startAt.millisecondsSinceEpoch,
        'consultType': consultType,
        'durationMin': durationMin,
        'status': status.name,
        'reason': reason,
        // Sort key — booking order (newest first); stored as epoch ms.
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

  factory Appointment.fromMap(Map<String, dynamic> m) => Appointment(
        id: m['id'] as String,
        specialistId: m['specialistId'] as String? ?? '',
        startAt: _readStartAt(m),
        consultType: m['consultType'] as String? ?? '',
        durationMin: (m['durationMin'] as num?)?.toInt() ?? 30,
        status: AppointmentStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => AppointmentStatus.upcoming,
        ),
        reason: m['reason'] as String? ?? '',
      );

  /// Reads the real start time, falling back to `createdAt` for legacy docs
  /// written before `startAt` existed (they stored only display strings).
  static DateTime _readStartAt(Map<String, dynamic> m) {
    final start = (m['startAt'] as num?)?.toInt();
    if (start != null) return DateTime.fromMillisecondsSinceEpoch(start);
    final created = (m['createdAt'] as num?)?.toInt();
    if (created != null) return DateTime.fromMillisecondsSinceEpoch(created);
    return DateTime.now();
  }
}

/// Sample appointments for the signed-out / offline demo only. Dates are
/// relative to "now" so the labels and Upcoming/Past tabs always look current.
final myAppointmentsMock = <Appointment>[
  Appointment(
    id: 'a1', specialistId: 's1',
    startAt: _mockAt(1, 10, 30),
    consultType: 'Video Call', durationMin: 30,
    status: AppointmentStatus.upcoming,
    reason: 'Persistent acne on cheeks and jawline.',
  ),
  Appointment(
    id: 'a2', specialistId: 's2',
    startAt: _mockAt(5, 14, 0),
    consultType: 'In-Person', durationMin: 45,
    status: AppointmentStatus.upcoming,
    reason: 'Increased hair fall over the past two months.',
  ),
  Appointment(
    id: 'a3', specialistId: 's3',
    startAt: _mockAt(-4, 11, 0),
    consultType: 'In-Person', durationMin: 45,
    status: AppointmentStatus.completed,
  ),
  Appointment(
    id: 'a4', specialistId: 's4',
    startAt: _mockAt(-14, 16, 0),
    consultType: 'Chat', durationMin: 20,
    status: AppointmentStatus.completed,
  ),
  Appointment(
    id: 'a6', specialistId: 's2',
    startAt: _mockAt(-9, 9, 0),
    consultType: 'Video Call', durationMin: 30,
    status: AppointmentStatus.missed,
  ),
  Appointment(
    id: 'a5', specialistId: 's1',
    startAt: _mockAt(-20, 9, 0),
    consultType: 'Video Call', durationMin: 30,
    status: AppointmentStatus.cancelled,
  ),
];

/// A date [dayOffset] days from today at [h]:[m], for sample data.
DateTime _mockAt(int dayOffset, int h, int m) {
  final now = DateTime.now();
  final base = DateTime(now.year, now.month, now.day).add(Duration(days: dayOffset));
  return DateTime(base.year, base.month, base.day, h, m);
}

// ── Date helpers (booking day picker) ─────────────────────────────────────────

const _weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Short weekday label for a date, e.g. "Tue".
String weekdayShort(DateTime d) => _weekdayShort[d.weekday - 1];

/// Month-day label, e.g. "Jun 9".
String monthDayLabel(DateTime d) => '${_monthShort[d.month - 1]} ${d.day}';

/// Relative day label: "Today, Jun 9" / "Tomorrow, Jun 10" /
/// "Yesterday, Jun 8" / "Tue, Jun 11".
String relativeDayLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = day.difference(today).inDays;
  if (diff == 0) return 'Today, ${monthDayLabel(d)}';
  if (diff == 1) return 'Tomorrow, ${monthDayLabel(d)}';
  if (diff == -1) return 'Yesterday, ${monthDayLabel(d)}';
  return '${weekdayShort(d)}, ${monthDayLabel(d)}';
}

/// 12-hour clock label for a date, e.g. "2:00 PM".
String timeLabel(DateTime d) {
  final ampm = d.hour >= 12 ? 'PM' : 'AM';
  var h = d.hour % 12;
  if (h == 0) h = 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m $ampm';
}

/// Combines a picked [day] with a 12-hour slot label like "2:00 PM" into a
/// real [DateTime]. Falls back to noon if the slot can't be parsed.
DateTime slotDateTime(DateTime day, String slot) {
  final match = RegExp(r'(\d{1,2}):(\d{2})\s*([AaPp][Mm])').firstMatch(slot);
  if (match == null) return DateTime(day.year, day.month, day.day, 12);
  var h = int.parse(match.group(1)!);
  final m = int.parse(match.group(2)!);
  final isPm = match.group(3)!.toUpperCase() == 'PM';
  if (isPm && h != 12) h += 12;
  if (!isPm && h == 12) h = 0;
  return DateTime(day.year, day.month, day.day, h, m);
}
