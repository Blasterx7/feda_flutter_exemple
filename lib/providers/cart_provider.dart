import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/shoe.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool isInCart(Shoe shoe, String size, String color) {
    return _items.any(
      (item) =>
          item.shoe.id == shoe.id &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );
  }

  void addItem(Shoe shoe, String size, String color) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.shoe.id == shoe.id &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(
        CartItem(shoe: shoe, selectedSize: size, selectedColor: color),
      );
    }
    notifyListeners();
  }

  void removeItem(String uniqueKey) {
    _items.removeWhere((item) => item.uniqueKey == uniqueKey);
    notifyListeners();
  }

  void incrementQuantity(String uniqueKey) {
    final index = _items.indexWhere((item) => item.uniqueKey == uniqueKey);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String uniqueKey) {
    final index = _items.indexWhere((item) => item.uniqueKey == uniqueKey);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
