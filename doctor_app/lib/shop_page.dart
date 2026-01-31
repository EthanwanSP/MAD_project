import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_shell.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final List<_ShopItem> _items = const [
    _ShopItem(
      id: 'wellness_pack',
      title: 'Wellness Pack',
      subtitle: 'Starter vitamins',
      imageUrl:
          'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=400',
      price: 24.99,
    ),
    _ShopItem(
      id: 'tele_consult',
      title: 'Tele Consult',
      subtitle: 'Anytime access',
      imageUrl:
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=400',
      price: 19.99,
    ),
    _ShopItem(
      id: 'lab_screening',
      title: 'Lab Screening',
      subtitle: 'Full panel',
      imageUrl:
          'https://images.unsplash.com/photo-1579154204601-01588f351e67?w=400',
      price: 59.99,
    ),
    _ShopItem(
      id: 'skin_care',
      title: 'Skin Care',
      subtitle: 'Derm-approved',
      imageUrl:
          'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400',
      price: 34.5,
    ),
    _ShopItem(
      id: 'herbal_tea',
      title: 'Herbal Tea',
      subtitle: 'Relaxation blend',
      imageUrl: 'https://ostrovit.com/data/include/img/news/1738059168.jpg',
      price: 12.0,
    ),
    _ShopItem(
      id: 'yoga_kit',
      title: 'Yoga Kit',
      subtitle: 'Complete set',
      imageUrl:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
      price: 28.0,
    ),
  ];

  Future<void> _recordPurchase(_ShopItem item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please log in to purchase items.'),
          backgroundColor: Colors.red.shade400,
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
                        onTap: () => _recordPurchase(item),
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
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
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
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
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
