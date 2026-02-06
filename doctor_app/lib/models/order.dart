import 'cart_item.dart';
import 'address.dart';

class Order {
  final String orderId;
  final String status;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final Address address;

  const Order({
    required this.orderId,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'status': status,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'address': address.toMap(),
    };
  }
}
