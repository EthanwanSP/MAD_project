import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/address.dart';
import '../services/firestore_service.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({FirestoreService? service})
      : _service = service ?? FirestoreService();

  final FirestoreService _service;
  Map<String, CartItem> _items = {};
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => _items.values.toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalQty => _items.values.fold(0, (sum, item) => sum + item.qty);
  double get subtotal =>
      _items.values.fold(0.0, (sum, item) => sum + item.subtotal);
  int quantityFor(String productId) => _items[productId]?.qty ?? 0;

  String? get _uid => _service.currentUser?.uid;

  Future<String> _requireUid() async {
    final existing = _uid;
    if (existing != null) return existing;
    if (kIsWeb) {
      try {
        final user = await FirebaseAuth.instance
            .authStateChanges()
            .firstWhere((u) => u != null)
            .timeout(const Duration(seconds: 2));
        if (user != null) return user.uid;
      } catch (_) {}
    }
    throw Exception('Please login to place order.');
  }

  Future<void> addProduct(Product product) async {
    final existing = _items[product.id];
    final updated = CartItem.fromProduct(
      product,
      qty: (existing?.qty ?? 0) + 1,
    );
    _items[product.id] = updated;
    notifyListeners();
  }

  Future<void> increment(String productId) async {
    final item = _items[productId];
    if (item == null) return;
    final updated = item.copyWith(qty: item.qty + 1);
    _items[productId] = updated;
    notifyListeners();
  }

  Future<void> decrement(String productId) async {
    final item = _items[productId];
    if (item == null) return;
    if (item.qty <= 1) {
      _items.remove(productId);
      notifyListeners();
      return;
    }
    final updated = item.copyWith(qty: item.qty - 1);
    _items[productId] = updated;
    notifyListeners();
  }

  Future<void> setQuantity(String productId, int qty) async {
    final item = _items[productId];
    if (item == null) return;
    if (qty <= 0) {
      _items.remove(productId);
      notifyListeners();
      return;
    }
    final updated = item.copyWith(qty: qty);
    _items[productId] = updated;
    notifyListeners();
  }

  Future<String> checkout(Address address) async {
    final uid = await _requireUid();
    final items = _items.values.toList();
    if (items.isEmpty) {
      throw Exception('Your cart is empty.');
    }
    _isLoading = true;
    notifyListeners();
    try {
      final orderId = await _service.placeOrder(
        uid: uid,
        items: items,
        address: address,
      );
      _items = {};
      _isLoading = false;
      notifyListeners();
      return orderId;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
