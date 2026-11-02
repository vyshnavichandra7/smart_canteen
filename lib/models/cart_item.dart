import 'food_item.dart';

class CartItem {
  const CartItem({required this.food, required this.quantity});

  final FoodItem food;
  final int quantity;

  double get total => food.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(food: food, quantity: quantity ?? this.quantity);

  Map<String, Object> toJson() => {'foodId': food.id, 'quantity': quantity};
}
