import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';

/// A lightweight in-app legal document viewer (Privacy Policy / Terms). Pushed
/// directly via [openLegalDoc] — no named route needed. Content is a concise,
/// readable summary; a full legal review is a pre-launch (post-investment) step.
class LegalDocScreen extends StatelessWidget {
  final String title;
  final String body;
  const LegalDocScreen({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: AppBar(
        backgroundColor: context.dColors.surface,
        elevation: 0,
        title: Text(title, style: AppTypography.h4),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.dColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Text(
          body,
          style: AppTypography.bodyMedium.copyWith(
            color: context.dColors.textSecondary,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

void openLegalDoc(BuildContext context, {required bool terms}) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => LegalDocScreen(
      title: terms ? 'Terms of Service' : 'Privacy Policy',
      body: terms ? _termsText : _privacyText,
    ),
  ));
}

void openUserGuide(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => const LegalDocScreen(title: 'User Guide', body: _guideText),
  ));
}

const _guideText = '''
Welcome to DermIQ — here's how to get the most out of the app.

1. Build your profile
Take the skin and hair quizzes after signing up. Your answers personalise your health score, analysis and product recommendations. You can revisit them any time from your profile.

2. Your Home dashboard
The DermIQ Health Score reflects your routine consistency. The cards below surface your top concerns, today's routine, and AI insights.

3. Scan products
Tap Scan to read a product's barcode or ingredient label. DermIQ checks ingredients against your profile and flags matches or conflicts. Demo barcodes work offline.

4. My Shelf
Find it inside Routine (under the AM/PM cards). Add products you own to track expiry and favourites — it syncs to your account.

5. Your Routine
Open the AM or PM routine and check off each step as you complete it. Completing routines builds your streak and updates your calendar (green = both done, yellow = one, red = missed).

6. Calendar & Progress
The calendar colours each day by how much of your routine you completed. Progress shows your score trend and key metrics over time.

7. Shop
Browse 80+ real products matched to your profile. Add to cart and check out with Cash on Delivery or online payment.

8. Book a specialist
From Find a Specialist, pick a doctor, choose a date and time, and confirm. Your bookings appear under My Appointments.

9. Ask the assistant
Tap the Chat tab to ask about ingredients, routines or concerns any time.

Need more help? Settings → Help & Support, or email help@dermiq.app.
''';

const _privacyText = '''
Last updated: June 2026

DermIQ ("we", "us") is committed to protecting your privacy. This summary explains what we collect and why.

What we collect
• Account details you provide (name, email) when you sign up.
• Your skin and hair quiz answers, routines, shelf, and scan history.
• Product photos and ingredient text you choose to scan, processed to give you analysis.
• Basic usage and crash diagnostics to improve the app.

How we use it
• To personalise your routine, analysis, and product recommendations.
• To sync your data securely to your account so it is available across sessions.
• We never sell your personal data.

Your control
• You can view and edit your profile and data from within the app.
• You can delete your account at any time from Settings → Privacy, which removes your data from our systems.

Storage & security
• Your data is stored with Google Firebase and encrypted in transit and at rest.

Contact
• Questions? Email help@dermiq.app.

This in-app summary is provided for transparency. A full legal policy will be published before public release.
''';

const _termsText = '''
Last updated: June 2026

Welcome to DermIQ. By using the app you agree to these terms.

Using DermIQ
• DermIQ provides skincare and haircare guidance, product information, and tools to track your routine.
• You must be 13 or older (or have guardian consent) to use the app.
• Keep your account credentials secure; you are responsible for activity on your account.

Not medical advice
• DermIQ's analysis, scores, and AI guidance are educational and informational only — they are not medical advice, diagnosis, or treatment.
• Always consult a qualified dermatologist for persistent, severe, or worsening skin or hair concerns.

Purchases
• Product listings, prices, and availability are subject to change. Orders are fulfilled per the checkout terms shown at purchase.

Content
• Product data and images may be sourced from third parties and are used for informational purposes.

Changes
• We may update these terms; continued use means you accept the changes.

Contact
• Questions? Email help@dermiq.app.

This in-app summary is provided for transparency. Full terms will be published before public release.
''';
