import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item.dart';
import '../models/address.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<List<CartItem>> streamCart(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CartItem.fromMap(doc.data()))
          .toList();
    });
  }

  Future<void> upsertCartItem(String uid, CartItem item) async {
    final doc = _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(item.productId);

    await doc.set({
      ...item.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeCartItem(String uid, String productId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  Future<void> clearCart(String uid) async {
    final cartSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .get();
    final batch = _firestore.batch();
    for (final doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<String> placeOrder({
    required String uid,
    required List<CartItem> items,
    required Address address,
  }) async {
    final orderRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('orders')
        .doc();

    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );
    const deliveryFee = 0.0;
    final total = subtotal + deliveryFee;

    final batch = _firestore.batch();

    batch.set(orderRef, {
      'orderId': orderRef.id,
      'status': 'placed',
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'address': address.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    final userRef = _firestore.collection('users').doc(uid);
    batch.set(userRef, {
      'defaultAddress': address.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final cartSnapshot = await userRef.collection('cart').get();
    for (final doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    return orderRef.id;
  }
}
