# DermIQ Phase 5 - Specialists, Appointments, Reviews & Medical Services

## Objective
Build a complete dermatologist and trichologist appointment ecosystem.

Do not redesign the UI.

## Specialist Types

- Dermatologist
- Trichologist

Display:
- Name
- Profile Image
- Qualification
- Experience
- Hospital/Clinic
- Rating
- Reviews
- Fee

## Filters

Functional filters:

- Dermatologist
- Trichologist
- Online
- In-Person
- Rating
- Price
- Experience

## Specialist Details

Display:
- Profile
- Experience
- Qualification
- Address
- Ratings
- Reviews
- Available Slots

Actions:
- Book Appointment
- Call Clinic
- Get Directions
- Save Specialist

## Booking Flow

Select:
- Specialist
- Date
- Time
- Consultation Mode

Modes:
- Online
- In-Person

Collect:
- Name
- Phone
- Email
- Notes

## Appointment Status

- Upcoming
- Completed
- Cancelled
- Missed

## Appointment Details

Display:
- Appointment ID
- Doctor
- Clinic
- Date
- Time
- Status

Actions:
- Reschedule
- Cancel
- Add To Calendar
- View Specialist

## Calendar Integration

Appointments appear in Calendar.

Display:
- Date
- Specialist
- Status
- Mode

## Notifications

Generate:
- Appointment Confirmed
- Reminder
- Rescheduled
- Cancelled

Notification click:
→ Appointment Details

## Reviews

Only completed appointments can review.

Allow:
- Rating (1–5)
- Review Text

Display:
- Average Rating
- Review Count
- User Reviews

## Saved Specialists

Profile
→ Saved Specialists

## Appointment History

Store:
- Upcoming
- Completed
- Cancelled
- Missed

Allow:
- View Details
- Rebook

## Profile Integration

Add:
- Appointments
- Saved Specialists
- Appointment History

## Data Storage

Store:
- Appointments
- Specialists
- Reviews
- Ratings
- Notifications
- Calendar Events

Use Firestore + local cache.

## Final Validation

Verify:
- Specialist listing
- Filters
- Booking
- Reschedule
- Cancellation
- Reviews
- Notifications
- Calendar Integration
- Saved Specialists

Maintain existing DermIQ UI exactly.
