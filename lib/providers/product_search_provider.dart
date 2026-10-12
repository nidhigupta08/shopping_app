
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductSearchNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void setQuery(String query) {
    state = query;
  }
}

final productSearchProvider =
NotifierProvider<ProductSearchNotifier, String>(
  ProductSearchNotifier.new,
);
