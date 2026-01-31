import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_shell.dart';
import 'cart_manager.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final List<_ShopItem> _items = const [
    _ShopItem(
      id: 'paracetamol_500',
      title: 'Paracetamol 500mg',
      subtitle: 'Pain & fever relief',
      imageUrl:
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
      price: 6.99,
    ),
    _ShopItem(
      id: 'ibuprofen_200',
      title: 'Ibuprofen 200mg',
      subtitle: 'Anti-inflammatory',
      imageUrl:
          'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=400',
      price: 8.49,
    ),
    _ShopItem(
      id: 'cetirizine_10',
      title: 'Cetirizine 10mg',
      subtitle: 'Allergy relief',
      imageUrl:
          'https://images.unsplash.com/photo-1628595351029-c2bf17511435?w=400',
      price: 9.99,
    ),
    _ShopItem(
      id: 'amoxicillin_500',
      title: 'Amoxicillin 500mg',
      subtitle: 'Antibiotic',
      imageUrl:
          'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400',
      price: 12.5,
    ),
    _ShopItem(
      id: 'omeprazole_20',
      title: 'Omeprazole 20mg',
      subtitle: 'Acid reducer',
      imageUrl:
          'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=400',
      price: 10.25,
    ),
    _ShopItem(
      id: 'vitamin_c_1000',
      title: 'Vitamin C 1000mg',
      subtitle: 'Immune support',
      imageUrl:
          'https://images.unsplash.com/photo-1576602975754-8d5f35b1ad56?w=400',
      price: 11.99,
    ),
    _ShopItem(
      id: 'loratadine_10',
      title: 'Loratadine 10mg',
      subtitle: 'Non-drowsy allergy',
      imageUrl:
          'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=400',
      price: 9.25,
    ),
  ];

  Future<void> _recordPurchase(_ShopItem item) async {
    CartManager().addItem(id: item.id, title: item.title, price: item.price);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Added to cart'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('purchases').add({
        'userId': user.uid,
        'itemId': item.id,
        'itemName': item.title,
        'price': item.price,
        'quantity': 1,
        'purchaseDate': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.title} added to purchases'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to record purchase.'),
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
    return Container(
      color: kPaper,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(top: 140), // Space for fixed header
            children: [
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Commonly Used',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: _items
                    .map(
                      (item) => _ShopCard(
                        title: item.title,
                        subtitle: item.subtitle,
                        imageUrl: item.imageUrl,
                        onAddToCart: () => _recordPurchase(item),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
          // Fixed header at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 22),
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
                            Text('Pharmacy', style: Theme.of(context).textTheme.titleLarge),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/cart');
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: kInk,
                          foregroundColor: kPaper,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                        label: const Text(
                          'Cart',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.onAddToCart,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
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
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: kPeach.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: kInk),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PT sarif',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PT sarif',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: onAddToCart,
                      style: FilledButton.styleFrom(
                        backgroundColor: kInk,
                        foregroundColor: kPaper,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Add to cart'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final double price;

  const _ShopItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.price,
  });
}
