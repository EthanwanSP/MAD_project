import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'app_theme.dart';
import 'auth_session.dart';
import 'cart_manager.dart';
import 'firebase_options.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartManager _cartManager = CartManager();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _cartManager.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartManager.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  TextEditingController _controllerFor(CartItem item) {
    return _controllers.putIfAbsent(
      item.id,
      () => TextEditingController(text: item.quantity.toString()),
    );
  }

  void _syncControllers(List<CartItem> items) {
    final ids = items.map((item) => item.id).toSet();
    _controllers.removeWhere((key, value) => !ids.contains(key));
    for (final item in items) {
      final controller = _controllerFor(item);
      if (controller.text != item.quantity.toString()) {
        controller.text = item.quantity.toString();
      }
    }
  }

  Future<void> _confirmCart() async {
    final items = _cartManager.items;
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your cart is empty'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (kIsWeb) {
      await _confirmCartWeb(items);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to confirm purchases'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    try {
      final batch = FirebaseFirestore.instance.batch();
      final userPurchases = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('purchases');
      for (final item in items) {
        final payload = {
          'userId': user.uid,
          'itemId': item.id,
          'itemName': item.title,
          'price': item.price,
          'quantity': item.quantity,
          'purchaseDate': FieldValue.serverTimestamp(),
        };
        batch.set(userPurchases.doc(), payload);
      }
      await batch.commit();

      if (mounted) {
        _cartManager.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cart saved to purchases'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to confirm cart: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _confirmCartWeb(List<CartItem> items) async {
    if (!AuthSession.isSignedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please sign in to confirm purchases'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return;
    }

    final projectId = DefaultFirebaseOptions.currentPlatform.projectId;
    final baseUserPurchasesUri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users/${AuthSession.userId}/purchases',
    );

    try {
      for (final item in items) {
        final docId = DateTime.now().microsecondsSinceEpoch.toString();
        final userPurchasesUri =
            Uri.parse('${baseUserPurchasesUri.toString()}?documentId=$docId');
        final body = {
          'fields': {
            'userId': {'stringValue': AuthSession.userId},
            'itemId': {'stringValue': item.id},
            'itemName': {'stringValue': item.title},
            'price': {'doubleValue': item.price},
            'quantity': {'integerValue': item.quantity},
            'purchaseDate': {
              'timestampValue': DateTime.now().toUtc().toIso8601String()
            },
          },
        };

        final userPurchasesResponse = await http.post(
          userPurchasesUri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthSession.idToken}',
          },
          body: jsonEncode(body),
        );
        if (userPurchasesResponse.statusCode != 200) {
          throw Exception('HTTP ${userPurchasesResponse.statusCode}');
        }
      }

      if (mounted) {
        _cartManager.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cart saved to purchases'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to confirm cart: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartManager.items;
    final total = _cartManager.total;
    _syncControllers(items);

    return Scaffold(
      backgroundColor: kPaper,
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: kBlush,
        foregroundColor: kInk,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'Your cart is empty',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kPaper,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kInk.withOpacity(0.08)),
                          boxShadow: [
                            BoxShadow(
                              color: kInk.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: kPeach.withOpacity(0.3),
                              child: const Icon(Icons.medication_outlined,
                                  color: kInk),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _cartManager.updateQuantity(
                                              item.id, -1);
                                        },
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                      ),
                                      SizedBox(
                                        width: 44,
                                        height: 32,
                                        child: TextField(
                                          controller: _controllerFor(item),
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          onChanged: (value) {
                                            if (value.isEmpty) return;
                                            final parsed =
                                                int.tryParse(value) ?? 0;
                                            if (parsed == 0) {
                                              _cartManager.removeItem(item.id);
                                              return;
                                            }
                                            _cartManager.setQuantity(
                                                item.id, parsed);
                                          },
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 6),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _cartManager.updateQuantity(
                                              item.id, 1);
                                        },
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text(
                                '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Text('Total:',
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Text('\$${total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _confirmCart,
                    style: FilledButton.styleFrom(
                      backgroundColor: kInk,
                      foregroundColor: kPaper,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
