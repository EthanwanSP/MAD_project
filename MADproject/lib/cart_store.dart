class CartItem {
  CartItem({required this.name, required this.price});

  final String name;
  final String price;
}

class CartStore {
  static final List<CartItem> _items = [];

  static List<CartItem> get items => List.unmodifiable(_items);

  static void addItem({
    required String itemName,
    required String price,
  }) {
    _items.add(CartItem(name: itemName, price: price));
  }

  static void clear() {
    _items.clear();
  }
}
