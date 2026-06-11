# DermIQ — Skills & Patterns Reference

Patterns already established in this codebase. Follow these when building new screens.

---

## Screen Template

Every feature screen follows this shape:

```dart
class XScreen extends ConsumerWidget {       // or ConsumerStatefulWidget if animation needed
  const XScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Title')),
      body: SingleChildScrollView(              // or ListView / CustomScrollView
        padding: const EdgeInsets.all(AppConstants.sp16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...],
        ),
      ),
    );
  }
}
```

---

## Riverpod Patterns

### Simple state (UI toggle, selection)
```dart
final selectedTabProvider = StateProvider<int>((ref) => 0);
// In widget: ref.watch(selectedTabProvider)
// In callback: ref.read(selectedTabProvider.notifier).state = 1
```

### Complex state (list, quiz, form)
```dart
class XNotifier extends StateNotifier<XState> {
  XNotifier() : super(const XState());
  void update(String v) => state = state.copyWith(field: v);
}
final xProvider = StateNotifierProvider<XNotifier, XState>((ref) => XNotifier());
```

### Async data (Firestore fetch)
```dart
final productsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  return ref.watch(productRepositoryProvider).getAll();
});
// In widget: ref.watch(productsProvider).when(data: ..., loading: ..., error: ...)
```

---

## Navigation

```dart
// Push (stack — back button returns)
context.push('/product/$id');
context.push('/analysis', extra: analysisId);

// Replace (no back button)
context.go('/home');

// After async — always guard
await doSomething();
if (context.mounted) context.go('/home');
```

---

## Shared Widgets

### AppCard
```dart
AppCard(
  padding: const EdgeInsets.all(16),
  onTap: () {},               // optional tap
  gradient: AppColors.gradientPrimary,  // optional — overrides color
  child: ...,
)
```

### GlassCard (for dark/gradient backgrounds)
```dart
GlassCard(
  padding: const EdgeInsets.all(20),
  child: ...,
)
```

### AppButton
```dart
AppButton(label: 'Save', onPressed: _save, isLoading: _saving)
AppButton(label: 'Cancel', isOutlined: true, onPressed: () {})
AppSocialButton(label: 'Google', icon: Icon(...), onPressed: _google)
```

---

## Color Usage

```dart
// Surfaces
AppColors.background     // scaffold background #F8F6FF
AppColors.surface        // card/sheet background #FFFFFF

// Brand
AppColors.primary        // #7C5CFF — buttons, active state, highlights
AppColors.accent         // #A78BFA — secondary accents, chips
AppColors.gradientPrimary // hero cards, CTAs

// Text
AppColors.textPrimary    // headings, labels
AppColors.textSecondary  // captions, hints

// Semantic
AppColors.success        // completion, positive metrics
AppColors.warning        // expiry, medium severity
AppColors.error          // errors, high severity

// Never use Colors.* directly in feature code
```

---

## Text Style Usage

```dart
Text('Heading', style: AppTextStyles.h3)
Text('Label', style: AppTextStyles.labelMedium)
Text('Body copy', style: AppTextStyles.bodyMedium)
Text('Caption / hint', style: AppTextStyles.caption)

// Override a property:
AppTextStyles.h4.copyWith(color: Colors.white)
AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)

// Never: TextStyle(fontFamily: 'Poppins', ...)
```

---

## Spacing

```dart
const SizedBox(height: AppConstants.sp16)   // between sections
const SizedBox(height: AppConstants.sp12)   // between items in a section
const SizedBox(height: AppConstants.sp8)    // between tightly related elements
EdgeInsets.all(AppConstants.sp16)           // screen padding
EdgeInsets.symmetric(horizontal: AppConstants.sp24, vertical: AppConstants.sp16)
```

---

## Animation Pattern (fade-in on screen enter)

```dart
class _XScreenState extends State<XScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _fade, child: ...);
}
```

---

## Charts (fl_chart)

### Line chart (Progress screen)
```dart
LineChart(LineChartData(
  gridData: FlGridData(
    drawVerticalLine: false,
    getDrawingHorizontalLine: (v) => FlLine(color: AppColors.accent.withValues(alpha: 0.1), strokeWidth: 1),
  ),
  borderData: FlBorderData(show: false),
  titlesData: FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    // ... left + bottom titles
  ),
  lineBarsData: [LineChartBarData(
    spots: [...],
    isCurved: true,
    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
    barWidth: 3,
    belowBarData: BarAreaData(show: true, gradient: ...),
  )],
))
```

---

## Firestore Repository Pattern (for Phase 2+)

```dart
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(firestoreProvider));
});

class ProductRepository {
  final FirebaseFirestore _db;
  ProductRepository(this._db);

  Stream<List<ProductModel>> watchAll(String userId) => _db
      .collection('products')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((s) => s.docs.map((d) => ProductModel.fromMap(d.data())).toList());

  Future<void> save(ProductModel p) =>
      _db.collection('products').doc(p.id).set(p.toMap());

  Future<void> delete(String id) =>
      _db.collection('products').doc(id).delete();
}
```

---

## Claude API Call Pattern (for Phase 5)

```dart
// Call via Cloud Function to keep API key server-side
Future<String> askClaude(String prompt, String skinContext) async {
  final response = await http.post(
    Uri.parse('https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/dermiqChat'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'prompt': prompt, 'skinContext': skinContext}),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body)['reply'] as String;
  }
  throw Exception('AI unavailable');
}

// Cloud Function calls:
// model: 'claude-sonnet-4-6'
// max_tokens: 1024
// system: 'You are a dermatology assistant. User skin type: {skinContext}. Be concise.'
```

---

## Modal Bottom Sheet Pattern

```dart
showModalBottomSheet(
  context: context,
  backgroundColor: AppColors.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  isScrollControlled: true,   // add if contains a text field
  builder: (_) => Padding(
    padding: EdgeInsets.only(
      left: 24, right: 24, top: 24,
      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
    ),
    child: ...,
  ),
);
```
