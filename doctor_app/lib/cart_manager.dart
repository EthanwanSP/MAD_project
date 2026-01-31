import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    this.quantity = 1,
  });
}

class CartManager extends ChangeNotifier {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  void addItem({required String id, required String title, required double price}) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].quantity += 1;
    } else {
      _items.add(CartItem(id: id, title: title, price: price));
    }
    notifyListeners();
  }

  void updateQuantity(String id, int delta) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final item = _items[index];
    item.quantity += delta;
    if (item.quantity < 1) {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void setQuantity(String id, int quantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    if (quantity < 1) return;
    _items[index].quantity = quantity;
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  double get total {
    double sum = 0;
    for (final item in _items) {
      sum += item.price * item.quantity;
    }
    return sum;
  }
}
