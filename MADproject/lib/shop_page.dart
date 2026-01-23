import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_shell.dart';
import 'login_page.dart';
import 'cart_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_store.dart';
import 'services/firestore_service.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  void _redirectToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _redirectToLogin());
      return const SizedBox.shrink();
    }

    final storeItems = [
      {'name': 'Pain Relief', 'price': '\$6'},
      {'name': 'Vitamin C', 'price': '\$9'},
      {'name': 'Allergy Ease', 'price': '\$12'},
      {'name': 'Cough Syrup', 'price': '\$8'},
      {'name': 'Antacid', 'price': '\$5'},
      {'name': 'Sleep Aid', 'price': '\$11'},
      {'name': 'Cold & Flu', 'price': '\$10'},
      {'name': 'Skin Cream', 'price': '\$7'},
      {'name': 'Eye Drops', 'price': '\$6'},
      {'name': 'Bandages', 'price': '\$4'},
      {'name': 'Energy Boost', 'price': '\$13'},
      {'name': 'Heart Health', 'price': '\$15'},
    ];

    return Container(
      color: kPaper,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
              decoration: const BoxDecoration(
                color: kBlush,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const HomeShell()),
                          );
                        },
                        icon: const Icon(Icons.arrow_back, color: kInk),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Medicines', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your medicines list',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CartPage()),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: const Text('Cart'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Online shop', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: storeItems.map((item) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kPaper,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: kInk.withOpacity(0.06)),
                      boxShadow: [
                        BoxShadow(
                          color: kInk.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: kPeach.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.medication_outlined, color: kInk),
                        ),
                        const SizedBox(height: 8),
                        Text(item['name']!, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(item['price']!, style: Theme.of(context).textTheme.bodySmall),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              CartStore.addItem(
                                itemName: item['name']!,
                                price: item['price']!,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${item['name']} added to cart.')),
                              );
                            },
                            child: const Text('Add to cart'),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Purchased medicines', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreService().streamMedicines(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final docs = (snapshot.data?.docs ?? []).where((doc) {
                  final data = doc.data();
                  return data['frequency'] == 'purchased';
                }).toList();
                if (docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
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
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.inventory_2_outlined, color: kInk),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No purchased medicines yet.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: kInk.withOpacity(0.7),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: docs.map((doc) {
                    final data = doc.data();
                    final name = (data['name'] ?? '') as String;
                    final price = (data['dosage'] ?? '') as String;
                    return Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kPaper,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: kInk.withOpacity(0.06)),
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
                            height: 40,
                            width: 40,
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
                                Text(name, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text(price, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: () {
                              FirestoreService().deleteMedicine(
                                uid: user.uid,
                                medicineId: doc.id,
                              );
                            },
                            child: const Text('Collect'),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
