import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'cart_store.dart';
import 'services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your cart.')),
      );
    }
    final items = CartStore.items;
    return Scaffold(
      backgroundColor: kPaper,
      appBar: AppBar(
        title: const Text('Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: items.isEmpty
                ? null
                : () {
                    setState(() => CartStore.clear());
                  },
            child: const Text('Clear'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (items.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: kPaper,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: kInk.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: kPeach.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shopping_cart_outlined, color: kInk),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your cart is empty.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: kInk.withOpacity(0.7),
                            ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kPaper,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: kInk.withOpacity(0.08)),
                        boxShadow: [
                          BoxShadow(
                            color: kInk.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: kPeach.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.medication_outlined, color: kInk),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text('Qty: 1', style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Text(item.price, style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: kInk,
                  foregroundColor: kPaper,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: items.isEmpty
                    ? null
                    : () async {
                        for (final item in items) {
                          await FirestoreService().addMedicine(
                            uid: user.uid,
                            name: item.name,
                            dosage: item.price,
                            frequency: 'purchased',
                          );
                        }
                        CartStore.clear();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Purchase confirmed.')),
                        );
                        Navigator.of(context).pop();
                      },
                child: const Text('Confirm purchase'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
