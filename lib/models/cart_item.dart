import 'shoe.dart';

class CartItem {
  final Shoe shoe;
  final String selectedSize;
  final String selectedColor;
  int quantity;

  CartItem({
    required this.shoe,
    required this.selectedSize,
    required this.selectedColor,
    this.quantity = 1,
  });

  double get totalPrice => shoe.price * quantity;

  String get uniqueKey => '${shoe.id}_${selectedSize}_$selectedColor';
}
