import 'package:flutter/foundation.dart';

import '../data/sample_menu.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';
import '../services/local_storage_service.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._storage);

  final LocalStorageService _storage;
  Map<String, CartItem> _items = {};

  List<CartItem> get items => List.unmodifiable(_items.values);
  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.values.fold(0, (sum, item) => sum + item.total);
  double get total => subtotal;
  bool get isEmpty => _items.isEmpty;

  Future<void> initialize() async {
    final menuById = {for (final item in sampleMenu) item.id: item};
    final restored = <String, CartItem>{};
    for (final savedItem in _storage.loadCart()) {
      final id = savedItem['foodId'];
      final quantity = savedItem['quantity'];
      final food = menuById[id];
      if (food == null || quantity is! int || quantity < 1) {
        throw const FormatException('Saved cart contains an invalid item.');
      }
      restored[id as String] = CartItem(food: food, quantity: quantity);
    }
    _items = restored;
    notifyListeners();
  }

  Future<void> add(FoodItem food) async {
    if (!food.isAvailable) {
      throw StateError('${food.name} is currently unavailable.');
    }
    final next = Map<String, CartItem>.from(_items);
    final existing = next[food.id];
    next[food.id] = CartItem(
      food: food,
      quantity: (existing?.quantity ?? 0) + 1,
    );
    await _commit(next);
  }

  Future<void> increment(String foodId) async {
    final item = _items[foodId];
    if (item == null) return;
    final next = Map<String, CartItem>.from(_items);
    next[foodId] = item.copyWith(quantity: item.quantity + 1);
    await _commit(next);
  }

  Future<void> decrement(String foodId) async {
    final item = _items[foodId];
    if (item == null) return;
    final next = Map<String, CartItem>.from(_items);
    if (item.quantity == 1) {
      next.remove(foodId);
    } else {
      next[foodId] = item.copyWith(quantity: item.quantity - 1);
    }
    await _commit(next);
  }

  Future<void> remove(String foodId) async {
    if (!_items.containsKey(foodId)) return;
    final next = Map<String, CartItem>.from(_items)..remove(foodId);
    await _commit(next);
  }

  Future<void> clear() async {
    if (_items.isEmpty) return;
    await _commit({});
  }

  Future<void> _commit(Map<String, CartItem> next) async {
    await _storage.saveCart(next.values.map((item) => item.toJson()).toList());
    _items = next;
    notifyListeners();
  }
}
