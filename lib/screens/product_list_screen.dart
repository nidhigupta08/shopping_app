
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_search_provider.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() =>
      _ProductListScreenState();
}

class _ProductListScreenState
    extends ConsumerState<ProductListScreen> {
  late final TextEditingController _searchController;
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;

  static const List<String> _categories = [
    'Electronics',
    'Clothing',
    'Accessories',
    'Footwear',
  ];

  String _sortOrder = 'default';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _minPriceController = TextEditingController();
    _maxPriceController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _openFilters(ProductFilters currentFilters) async {
    _minPriceController.text =
        currentFilters.minPrice?.toString() ?? '';
    _maxPriceController.text =
        currentFilters.maxPrice?.toString() ?? '';

    String? selectedCategory = currentFilters.category;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  20 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Filters',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                selectedCategory = null;
                                _minPriceController.clear();
                                _maxPriceController.clear();
                              });
                            },
                            child: const Text('Clear all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: selectedCategory == null,
                            onSelected: (_) {
                              setSheetState(() {
                                selectedCategory = null;
                              });
                            },
                          ),
                          ..._categories.map(
                                (category) => ChoiceChip(
                              label: Text(category),
                              selected:
                              selectedCategory == category,
                              onSelected: (_) {
                                setSheetState(() {
                                  selectedCategory = category;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Price range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _minPriceController,
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Minimum (₹)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _maxPriceController,
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Maximum (₹)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setSheetState(() {
                                  selectedCategory = null;
                                  _minPriceController.clear();
                                  _maxPriceController.clear();
                                });
                              },
                              child: const Text('Clear all'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                final minText =
                                _minPriceController.text.trim();
                                final maxText =
                                _maxPriceController.text.trim();

                                final minPrice = minText.isEmpty
                                    ? null
                                    : double.tryParse(minText);
                                final maxPrice = maxText.isEmpty
                                    ? null
                                    : double.tryParse(maxText);

                                if ((minText.isNotEmpty &&
                                    (minPrice == null ||
                                        minPrice < 0)) ||
                                    (maxText.isNotEmpty &&
                                        (maxPrice == null ||
                                            maxPrice < 0))) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Enter valid, non-negative prices.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (minPrice != null &&
                                    maxPrice != null &&
                                    minPrice > maxPrice) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Minimum price cannot exceed maximum price.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final notifier = ref.read(
                                  productFilterProvider.notifier,
                                );

                                notifier.setCategory(selectedCategory);
                                notifier.setMinPrice(minPrice);
                                notifier.setMaxPrice(maxPrice);

                                Navigator.pop(sheetContext);
                              },
                              child: const Text('Apply filters'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openSortOptions() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: RadioGroup<String>(
            groupValue: _sortOrder,
            onChanged: (value) {
              if (value != null) {
                Navigator.pop(context, value);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                ListTile(
                  title: Text(
                    'Sort by',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                RadioListTile<String>(
                  title: Text('Recommended'),
                  value: 'default',
                ),
                RadioListTile<String>(
                  title: Text('Price: Low to High'),
                  value: 'lowToHigh',
                ),
                RadioListTile<String>(
                  title: Text('Price: High to Low'),
                  value: 'highToLow',
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _sortOrder = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final productsState = ref.watch(productProvider);
    final searchQuery = ref.watch(productSearchProvider);
    final filters = ref.watch(productFilterProvider);

    final cartCount = cartItems.fold<int>(
      0,
          (sum, item) => sum + item.quantity,
    );

    final activeFilterCount = [
      if (filters.category != null) filters.category,
      if (filters.minPrice != null) filters.minPrice,
      if (filters.maxPrice != null) filters.maxPrice,
    ].length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping App'),
        actions: [
          IconButton(
            tooltip: 'Refresh products',
            onPressed: () => ref.invalidate(productProvider),
            icon: const Icon(Icons.refresh),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Shopping cart',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$cartCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref
                    .read(productSearchProvider.notifier)
                    .setQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref
                        .read(productSearchProvider.notifier)
                        .setQuery('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openFilters(filters),
                    icon: const Icon(Icons.tune),
                    label: Text(
                      activeFilterCount > 0
                          ? 'Filter ($activeFilterCount)'
                          : 'Filter',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openSortOptions,
                    icon: const Icon(Icons.swap_vert),
                    label: const Text('Sort'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: productsState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      const Text('Failed to load products.'),
                      const SizedBox(height: 8),
                      Text(
                        '$error',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.invalidate(productProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (products) {
                final normalizedQuery =
                searchQuery.trim().toLowerCase();

                final filteredProducts = products.where((product) {
                  return product.name
                      .toLowerCase()
                      .contains(normalizedQuery);
                }).toList();

                if (_sortOrder == 'lowToHigh') {
                  filteredProducts.sort(
                        (a, b) => a.price.compareTo(b.price),
                  );
                } else if (_sortOrder == 'highToLow') {
                  filteredProducts.sort(
                        (a, b) => b.price.compareTo(a.price),
                  );
                }

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Text(
                      normalizedQuery.isEmpty
                          ? 'No products found'
                          : 'No matching products found',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];

                    return ProductCard(
                      product: product,
                      onAddToCart: () {
                        ref
                            .read(cartProvider.notifier)
                            .addToCart(product);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.name} added to cart',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailsScreen(
                                  product: product,
                                ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
