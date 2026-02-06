import 'product.dart';

class CartItem {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final int qty;

  const CartItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.qty,
  });

  double get subtotal => price * qty;

  CartItem copyWith({
    String? productId,
    String? name,
    String? imageUrl,
    double? price,
    int? qty,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      qty: qty ?? this.qty,
    );
  }

  static CartItem fromProduct(Product product, {int qty = 1}) {
    return CartItem(
      productId: product.id,
      name: product.name,
      imageUrl: product.imageUrl,
      price: product.price,
      qty: qty,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'qty': qty,
    };
  }

  static CartItem fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      qty: (map['qty'] as num?)?.toInt() ?? 0,
    );
  }
}
