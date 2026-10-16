
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../services/product_api_service.dart';

class ProductFilters {
  final String? category;
  final double? minPrice;
  final double? maxPrice;

  const ProductFilters({
    this.category,
    this.minPrice,
    this.maxPrice,
  });

  ProductFilters copyWith({
    String? category,
    double? minPrice,
    double? maxPrice,
    bool clearCategory = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return ProductFilters(
      category: clearCategory ? null : category ?? this.category,
      minPrice: clearMinPrice ? null : minPrice ?? this.minPrice,
      maxPrice: clearMaxPrice ? null : maxPrice ?? this.maxPrice,
    );
  }
}

class ProductFilterNotifier extends Notifier<ProductFilters> {
  @override
  ProductFilters build() => const ProductFilters();

  void setCategory(String? category) {
    state = state.copyWith(
      category: category,
      clearCategory: category == null || category.isEmpty,
    );
  }

  void setMinPrice(double? price) {
    state = state.copyWith(
      minPrice: price,
      clearMinPrice: price == null,
    );
  }

  void setMaxPrice(double? price) {
    state = state.copyWith(
      maxPrice: price,
      clearMaxPrice: price == null,
    );
  }

  void clearFilters() {
    state = const ProductFilters();
  }
}

final productFilterProvider =
NotifierProvider<ProductFilterNotifier, ProductFilters>(
  ProductFilterNotifier.new,
);

class ProductNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final filters = ref.watch(productFilterProvider);
    final apiService = ProductApiService();

    final data = await apiService.fetchProducts(
      category: filters.category,
      minPrice: filters.minPrice,
      maxPrice: filters.maxPrice,
    );

    return data
        .map(
          (json) => Product.fromJson(
        Map<String, dynamic>.from(json),
      ),
    )
        .toList();
  }
}

final productProvider =
AsyncNotifierProvider<ProductNotifier, List<Product>>(
  ProductNotifier.new,
);
