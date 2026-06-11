import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/shop_models.dart';
import '../../data/shop_seed.dart';
import '../../providers/cart_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShopScreen
// ─────────────────────────────────────────────────────────────────────────────

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _activeTab = 0;
  String _query = '';
  Set<String> _selectedBrands = {};
  double _minPrice = 0;
  double _maxPrice = 5000;
  double _minRating = 0;
  String _sortBy = 'Featured';

  static const _sortOptions = [
    'Featured',
    'Price: Low to High',
    'Price: High to Low',
    'Rating',
    'DermIQ Match',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (_tabController.indexIsChanging) {
          setState(() => _activeTab = _tabController.index);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> _brandsFor(List<ShopProduct> products) =>
      products.map((p) => p.brand).toSet().toList()..sort();

  List<ShopProduct> _filter(List<ShopProduct> products) {
    var list = products.where((p) {
      final q = _query.toLowerCase();
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.subCategory.toLowerCase().contains(q);
      final matchesBrand =
          _selectedBrands.isEmpty || _selectedBrands.contains(p.brand);
      final matchesPrice = p.price >= _minPrice && p.price <= _maxPrice;
      final matchesRating = p.rating >= _minRating;
      return matchesQuery && matchesBrand && matchesPrice && matchesRating;
    }).toList();

    switch (_sortBy) {
      case 'Price: Low to High':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'DermIQ Match':
        list.sort((a, b) => b.dermiqMatchScore.compareTo(a.dermiqMatchScore));
        break;
      default: // Featured
        list.sort((a, b) => (b.isFeatured ? 1 : 0) - (a.isFeatured ? 1 : 0));
    }
    return list;
  }

  void _addToCart(ShopProduct product) {
    ref.read(cartProvider.notifier).addItem(product);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product.name} added to cart',
          style: AppTypography.labelMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final skincareList = _filter(skincare);
    final haircareList = _filter(haircare);
    final allBrands = _brandsFor(
      _activeTab == 0 ? skincare : haircare,
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.dColors.background,
      endDrawer: _FilterDrawer(
        brands: allBrands,
        selectedBrands: _selectedBrands,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minRating: _minRating,
        sortBy: _sortBy,
        sortOptions: _sortOptions,
        onApply: ({
          required Set<String> brands,
          required double minPrice,
          required double maxPrice,
          required double minRating,
          required String sortBy,
        }) {
          setState(() {
            _selectedBrands = brands;
            _minPrice = minPrice;
            _maxPrice = maxPrice;
            _minRating = minRating;
            _sortBy = sortBy;
          });
          Navigator.of(context).pop();
        },
        onReset: () {
          setState(() {
            _selectedBrands = {};
            _minPrice = 0;
            _maxPrice = 5000;
            _minRating = 0;
            _sortBy = 'Featured';
          });
          Navigator.of(context).pop();
        },
      ),
      appBar: AppBar(
        backgroundColor: context.dColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Shop',
          style: AppTypography.h3.copyWith(color: context.dColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune_rounded, color: context.dColors.textPrimary),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            tooltip: 'Filter',
          ),
          const SizedBox(width: AppConstants.sp8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: context.dColors.borderLight),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ────────────────────────────────────────────────────
          _SearchBar(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),

          // ── Tab Bar ───────────────────────────────────────────────────────
          Container(
            color: context.dColors.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: context.dColors.textSecondary,
              labelStyle: AppTypography.labelMedium,
              unselectedLabelStyle: AppTypography.labelMedium,
              tabs: const [
                Tab(text: 'Skincare'),
                Tab(text: 'Haircare'),
              ],
            ),
          ),

          // ── Product Grid ──────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ProductGrid(
                  products: skincareList,
                  onTap: (p) => context.push('/shop/product/${p.id}', extra: p),
                  onAddToCart: _addToCart,
                ),
                _ProductGrid(
                  products: haircareList,
                  onTap: (p) => context.push('/shop/product/${p.id}', extra: p),
                  onAddToCart: _addToCart,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SearchBar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.dColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.screenPaddingH,
        AppConstants.sp12,
        AppConstants.screenPaddingH,
        AppConstants.sp12,
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: context.dColors.surfaceDim,
          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
          border: Border.all(color: context.dColors.borderLight),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: AppTypography.bodyMedium.copyWith(
            color: context.dColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search products, brands…',
            hintStyle: AppTypography.bodyMedium,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: context.dColors.textTertiary,
              size: 20,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: context.dColors.textTertiary,
                      size: 18,
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppConstants.sp12,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProductGrid
// ─────────────────────────────────────────────────────────────────────────────

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.products,
    required this.onTap,
    required this.onAddToCart,
  });

  final List<ShopProduct> products;
  final ValueChanged<ShopProduct> onTap;
  final ValueChanged<ShopProduct> onAddToCart;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 48, color: context.dColors.textTertiary),
            const SizedBox(height: AppConstants.sp12),
            Text(
              'No products found',
              style: AppTypography.labelMedium
                  .copyWith(color: context.dColors.textSecondary),
            ),
            const SizedBox(height: AppConstants.sp4),
            Text(
              'Try adjusting your filters',
              style: AppTypography.caption,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = AppConstants.screenPaddingH;
        const spacing = AppConstants.sp16;
        final availableWidth = constraints.maxWidth - padding * 2;

        // Responsive column count: 3 on tablets/large widths, else 2.
        final crossAxisCount = availableWidth >= 640 ? 3 : 2;

        // Width of a single card given the chosen column count.
        final cardWidth =
            (availableWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;

        // The card is a Column split by flex 11 (image) / 10 (info). The info
        // area packs brand + 2-line name + match + price + rating + a 36px
        // button with gaps, needing a roughly fixed vertical budget regardless
        // of card width. Size the card so the info flex-slice (10/21 of the
        // card height) always clears that budget, then derive an aspect ratio.
        const infoBudget = 200.0; // min px the info area must receive
        const infoFlexFraction = 10 / 21;
        final imageHeight = cardWidth; // square-ish image area
        // Card height must satisfy both: image slice >= imageHeight AND
        // info slice (10/21) >= infoBudget. Take the larger requirement.
        final cardHeight =
            (imageHeight / (11 / 21)) > (infoBudget / infoFlexFraction)
                ? imageHeight / (11 / 21)
                : infoBudget / infoFlexFraction;
        final childAspectRatio = cardWidth / cardHeight;

        return GridView.builder(
          padding: const EdgeInsets.all(padding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: products.length,
          itemBuilder: (context, i) {
            return _ShopProductCard(
              product: products[i],
              onTap: () => onTap(products[i]),
              onAddToCart: () => onAddToCart(products[i]),
            )
                .animate(delay: Duration(milliseconds: 60 * i))
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ShopProductCard
// ─────────────────────────────────────────────────────────────────────────────

class _ShopProductCard extends StatelessWidget {
  const _ShopProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  final ShopProduct product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.dColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          boxShadow: context.dColors.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product image area ────────────────────────────────────────
            Expanded(
              flex: 11,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          product.accentColor.withValues(alpha: 0.15),
                          product.accentColor.withValues(alpha: 0.35),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: context.dColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: product.accentColor.withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            product.brand[0].toUpperCase(),
                            style: AppTypography.h3.copyWith(
                              color: product.accentColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Discount badge
                  if (product.hasDiscount)
                    Positioned(
                      top: AppConstants.sp8,
                      right: AppConstants.sp8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.sp8,
                          vertical: AppConstants.sp4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusXS),
                        ),
                        child: Text(
                          product.discountStr,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),

                  // Featured badge
                  if (product.isFeatured)
                    Positioned(
                      top: AppConstants.sp8,
                      left: AppConstants.sp8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.sp8,
                          vertical: AppConstants.sp4,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusXS),
                        ),
                        child: Text(
                          'Featured',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Product info ──────────────────────────────────────────────
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.sp12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand
                    Text(
                      product.brand.toUpperCase(),
                      style: AppTypography.overline.copyWith(
                        color: context.dColors.textTertiary,
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.sp4),

                    // Name
                    Text(
                      product.name,
                      style: AppTypography.labelMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.sp4),

                    // DermIQ Match
                    Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded,
                            size: 12, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Text(
                          '${product.dermiqMatchScore}% match',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.sp4),

                    // Price row
                    Row(
                      children: [
                        Text(
                          product.priceStr,
                          style: AppTypography.h4.copyWith(
                            color: AppColors.primary,
                            fontSize: 15,
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: AppConstants.sp4),
                          Text(
                            product.originalPriceStr,
                            style: AppTypography.caption.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: context.dColors.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppConstants.sp4),

                    // Rating row
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 13, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: AppTypography.labelSmall.copyWith(
                            color: context.dColors.textPrimary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: AppConstants.sp4),
                        Text(
                          '(${product.reviewCount})',
                          style: AppTypography.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Add to Cart button
                    GestureDetector(
                      onTap: onAddToCart,
                      child: Container(
                        width: double.infinity,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSmall),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Add to Cart',
                          style: AppTypography.buttonSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FilterDrawer
// ─────────────────────────────────────────────────────────────────────────────

class _FilterDrawer extends StatefulWidget {
  const _FilterDrawer({
    required this.brands,
    required this.selectedBrands,
    required this.minPrice,
    required this.maxPrice,
    required this.minRating,
    required this.sortBy,
    required this.sortOptions,
    required this.onApply,
    required this.onReset,
  });

  final List<String> brands;
  final Set<String> selectedBrands;
  final double minPrice;
  final double maxPrice;
  final double minRating;
  final String sortBy;
  final List<String> sortOptions;
  final void Function({
    required Set<String> brands,
    required double minPrice,
    required double maxPrice,
    required double minRating,
    required String sortBy,
  }) onApply;
  final VoidCallback onReset;

  @override
  State<_FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<_FilterDrawer> {
  late Set<String> _brands;
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;
  late double _minRating;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    _brands = Set.from(widget.selectedBrands);
    _minCtrl =
        TextEditingController(text: widget.minPrice > 0 ? '${widget.minPrice.toInt()}' : '');
    _maxCtrl = TextEditingController(
        text: widget.maxPrice < 5000 ? '${widget.maxPrice.toInt()}' : '');
    _minRating = widget.minRating;
    _sortBy = widget.sortBy;
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      backgroundColor: context.dColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.sp24,
                AppConstants.sp16,
                AppConstants.sp8,
                AppConstants.sp12,
              ),
              child: Row(
                children: [
                  Text('Filters', style: AppTypography.h3),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: context.dColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: context.dColors.borderLight),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.sp24),
                children: [
                  // Sort By
                  Text('Sort By', style: AppTypography.labelLarge),
                  const SizedBox(height: AppConstants.sp8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.sp16,
                      vertical: AppConstants.sp4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.dColors.borderMedium),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        isExpanded: true,
                        style: AppTypography.bodyMedium
                            .copyWith(color: context.dColors.textPrimary),
                        items: widget.sortOptions
                            .map((o) => DropdownMenuItem(
                                  value: o,
                                  child: Text(o),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _sortBy = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.sp24),

                  // Brand Filter
                  if (widget.brands.isNotEmpty) ...[
                    Text('Brand', style: AppTypography.labelLarge),
                    const SizedBox(height: AppConstants.sp8),
                    Wrap(
                      spacing: AppConstants.sp8,
                      runSpacing: AppConstants.sp8,
                      children: widget.brands.map((brand) {
                        final selected = _brands.contains(brand);
                        return FilterChip(
                          label: Text(
                            brand,
                            style: AppTypography.labelSmall.copyWith(
                              color: selected
                                  ? Colors.white
                                  : context.dColors.textSecondary,
                            ),
                          ),
                          selected: selected,
                          selectedColor: AppColors.primary,
                          backgroundColor: context.dColors.surfaceDim,
                          checkmarkColor: Colors.white,
                          side: BorderSide(
                            color: selected
                                ? AppColors.primary
                                : context.dColors.borderLight,
                          ),
                          onSelected: (v) => setState(() {
                            if (v) {
                              _brands.add(brand);
                            } else {
                              _brands.remove(brand);
                            }
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppConstants.sp24),
                  ],

                  // Price Range
                  Text('Price Range (₹)', style: AppTypography.labelLarge),
                  const SizedBox(height: AppConstants.sp8),
                  Row(
                    children: [
                      Expanded(
                        child: _PriceField(
                          controller: _minCtrl,
                          hint: 'Min',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.sp8,
                        ),
                        child: Text('–',
                            style: AppTypography.bodyMedium
                                .copyWith(color: context.dColors.textPrimary)),
                      ),
                      Expanded(
                        child: _PriceField(
                          controller: _maxCtrl,
                          hint: 'Max',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.sp24),

                  // Rating Filter
                  Text('Minimum Rating', style: AppTypography.labelLarge),
                  const SizedBox(height: AppConstants.sp8),
                  Wrap(
                    spacing: AppConstants.sp8,
                    runSpacing: AppConstants.sp8,
                    children: [
                      _RatingChip(
                        label: 'All',
                        selected: _minRating == 0,
                        onTap: () => setState(() => _minRating = 0),
                      ),
                      _RatingChip(
                        label: '4+',
                        selected: _minRating == 4.0,
                        onTap: () => setState(() => _minRating = 4.0),
                      ),
                      _RatingChip(
                        label: '4.5+',
                        selected: _minRating == 4.5,
                        onTap: () => setState(() => _minRating = 4.5),
                      ),
                      _RatingChip(
                        label: '4.8+',
                        selected: _minRating == 4.8,
                        onTap: () => setState(() => _minRating = 4.8),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Apply / Reset buttons
            Container(
              padding: const EdgeInsets.all(AppConstants.sp16),
              decoration: BoxDecoration(
                color: context.dColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onReset,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(color: context.dColors.borderMedium),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusButton),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Reset',
                          style: AppTypography.button.copyWith(
                            color: context.dColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.sp12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final minP = double.tryParse(_minCtrl.text) ?? 0;
                        final maxP =
                            double.tryParse(_maxCtrl.text) ?? 5000;
                        widget.onApply(
                          brands: _brands,
                          minPrice: minP,
                          maxPrice: maxP,
                          minRating: _minRating,
                          sortBy: _sortBy,
                        );
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusButton),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Apply',
                          style: AppTypography.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PriceField extends StatelessWidget {
  const _PriceField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: context.dColors.surfaceDim,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: context.dColors.borderLight),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: AppTypography.bodyMedium.copyWith(color: context.dColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.caption,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.sp12,
            vertical: AppConstants.sp12,
          ),
          prefixText: '₹',
          prefixStyle:
              AppTypography.caption.copyWith(color: context.dColors.textSecondary),
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.sp16,
          vertical: AppConstants.sp8,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : context.dColors.surfaceDim,
          borderRadius: BorderRadius.circular(AppConstants.radiusButton),
          border: Border.all(
            color: selected ? AppColors.primary : context.dColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != 'All')
              Icon(
                Icons.star_rounded,
                size: 13,
                color: selected ? Colors.white : AppColors.warning,
              ),
            if (label != 'All') const SizedBox(width: 3),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: selected ? Colors.white : context.dColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
