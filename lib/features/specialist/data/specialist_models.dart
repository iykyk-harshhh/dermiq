import 'package:flutter/material.dart';

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

  /// Two-letter initials derived from the name (skips a leading "Dr.").
  String get initials {
    final clean = name.replaceFirst('Dr. ', '').trim();
    final parts = clean.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean.substring(0, 2).toUpperCase();
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
  final String dateLabel; // e.g. 'Today, Jun 9'
  final String time;
  final String consultType;
  final int durationMin;
  final double fee;

  const BookingDraft({
    required this.specialistId,
    required this.dateLabel,
    required this.time,
    required this.consultType,
    required this.durationMin,
    required this.fee,
  });
}

// ── Appointment (My Appointments) ─────────────────────────────────────────────

enum AppointmentStatus { upcoming, completed, cancelled, missed }

class Appointment {
  final String id;
  final String specialistId;
  final String dateLabel;
  final String time;
  final String consultType;
  final int durationMin;
  final AppointmentStatus status;

  const Appointment({
    required this.id,
    required this.specialistId,
    required this.dateLabel,
    required this.time,
    required this.consultType,
    required this.durationMin,
    required this.status,
  });

  Specialist get specialist => lookupSpecialist(specialistId);
}

final myAppointmentsMock = <Appointment>[
  Appointment(
    id: 'a1', specialistId: 's1',
    dateLabel: 'Tomorrow, Jun 10', time: '10:30 AM',
    consultType: 'Video Call', durationMin: 30,
    status: AppointmentStatus.upcoming,
  ),
  Appointment(
    id: 'a2', specialistId: 's2',
    dateLabel: 'Mon, Jun 15', time: '2:00 PM',
    consultType: 'In-Person', durationMin: 45,
    status: AppointmentStatus.upcoming,
  ),
  Appointment(
    id: 'a3', specialistId: 's3',
    dateLabel: 'May 28', time: '11:00 AM',
    consultType: 'In-Person', durationMin: 45,
    status: AppointmentStatus.completed,
  ),
  Appointment(
    id: 'a4', specialistId: 's4',
    dateLabel: 'May 12', time: '4:00 PM',
    consultType: 'Chat', durationMin: 20,
    status: AppointmentStatus.completed,
  ),
  Appointment(
    id: 'a5', specialistId: 's1',
    dateLabel: 'Apr 30', time: '9:00 AM',
    consultType: 'Video Call', durationMin: 30,
    status: AppointmentStatus.cancelled,
  ),
];

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
