import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../services/product_api_service.dart';

class ProductNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final apiService = ProductApiService();

    final data = await apiService.fetchProducts();

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