import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dermiq/shared/widgets/widgets.dart';

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('AppButton', () {
    testWidgets('renders label and fires onPressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_host(
        AppButton(label: 'Go', onPressed: () => tapped = true),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Go'), findsOneWidget);
      await tester.tap(find.text('Go'));
      expect(tapped, isTrue);
    });

    testWidgets('loading shows a spinner instead of the label', (tester) async {
      await tester.pumpWidget(_host(
        const AppButton(label: 'Go', isLoading: true),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Go'), findsNothing);
    });
  });

  testWidgets('AppToggleTile reports switch changes', (tester) async {
    bool? captured;
    await tester.pumpWidget(_host(
      AppToggleTile(
        icon: Icons.alarm, color: Colors.purple, label: 'Reminders',
        value: false, onChanged: (v) => captured = v,
      ),
    ));
    expect(find.text('Reminders'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    expect(captured, isTrue);
  });

  testWidgets('AppSettingsTile fires onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_host(
      AppSettingsTile(icon: Icons.lock, label: 'Privacy', onTap: () => tapped = true),
    ));
    await tester.tap(find.text('Privacy'));
    expect(tapped, isTrue);
  });

  testWidgets('AppSectionCard renders an uppercase overline title', (tester) async {
    await tester.pumpWidget(_host(
      const AppSectionCard(title: 'Account', children: [Text('row')]),
    ));
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('row'), findsOneWidget);
  });

  testWidgets('EmptyState shows title, subtitle and action', (tester) async {
    var acted = false;
    await tester.pumpWidget(_host(
      EmptyState(
        title: 'Nothing here', subtitle: 'Add something', icon: Icons.inbox,
        actionLabel: 'Add', onAction: () => acted = true,
      ),
    ));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Add something'), findsOneWidget);
    await tester.tap(find.text('Add'));
    expect(acted, isTrue);
  });

  testWidgets('AppChip renders label and fires onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_host(
      AppChip(label: 'Oily', isSelected: true, onTap: () => tapped = true),
    ));
    expect(find.text('Oily'), findsOneWidget);
    await tester.tap(find.text('Oily'));
    expect(tapped, isTrue);
  });

  testWidgets('ScoreRing builds and animates', (tester) async {
    await tester.pumpWidget(_host(const ScoreRing(score: 82)));
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.byType(ScoreRing), findsOneWidget);
  });

  testWidgets('AppSnackbar shows a floating message', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AppSnackbar.success(context, 'Saved!'),
            child: const Text('save'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('save'));
    await tester.pump(); // let the snackbar appear
    expect(find.text('Saved!'), findsOneWidget);
  });
}
