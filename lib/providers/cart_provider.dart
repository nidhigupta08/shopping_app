import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [];
  }

  void addToCart(Product product) {
    final existingIndex = state.indexWhere(
          (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      final updatedCart = [...state];
      updatedCart[existingIndex].quantity++;
      state = updatedCart;
    } else {
      state = [
        ...state,
        CartItem(product: product),
      ];
    }
  }

  void increaseQuantity(Product product) {
    final updatedCart = [...state];

    final index = updatedCart.indexWhere(
          (item) => item.product.id == product.id,
    );

    if (index != -1) {
      updatedCart[index].quantity++;
      state = updatedCart;
    }
  }

  void decreaseQuantity(Product product) {
    final updatedCart = [...state];

    final index = updatedCart.indexWhere(
          (item) => item.product.id == product.id,
    );

    if (index != -1) {
      if (updatedCart[index].quantity > 1) {
        updatedCart[index].quantity--;
      } else {
        updatedCart.removeAt(index);
      }

      state = updatedCart;
    }
  }

  void removeFromCart(Product product) {
    state = state
        .where((item) => item.product.id != product.id)
        .toList();
  }

  double get totalAmount {
    return state.fold(
      0,
          (total, item) =>
      total + (item.product.price * item.quantity),
    );
  }
}

final cartProvider =
NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);