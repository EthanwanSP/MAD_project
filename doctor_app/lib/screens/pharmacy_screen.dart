import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_badge.dart';
import '../home_shell.dart';

class PharmacyScreen extends StatelessWidget {
  const PharmacyScreen({super.key});

  static const List<Product> _products = [
    Product(
      id: 'paracetamol_500',
      name: 'Paracetamol 500mg',
      description: 'Pain & fever relief',
      imageUrl:
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800',
      price: 6.99,
    ),
    Product(
      id: 'ibuprofen_200',
      name: 'Ibuprofen 200mg',
      description: 'Anti-inflammatory',
      imageUrl:
          'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=800',
      price: 8.49,
    ),
    Product(
      id: 'cetirizine_10',
      name: 'Cetirizine 10mg',
      description: 'Allergy relief',
      imageUrl:
          'https://images.unsplash.com/photo-1628595351029-c2bf17511435?w=800',
      price: 9.99,
    ),
    Product(
      id: 'amoxicillin_500',
      name: 'Amoxicillin 500mg',
      description: 'Antibiotic',
      imageUrl:
          'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=800',
      price: 12.50,
    ),
    Product(
      id: 'omeprazole_20',
      name: 'Omeprazole 20mg',
      description: 'Acid reducer',
      imageUrl:
          'https://images.unsplash.com/photo-1512069772995-ec65ed45afd6?w=800',
      price: 10.25,
    ),
    Product(
      id: 'vitamin_c_1000',
      name: 'Vitamin C 1000mg',
      description: 'Immune support',
      imageUrl:
          'https://images.unsplash.com/photo-1576602975754-8d5f35b1ad56?w=800',
      price: 11.99,
    ),
    Product(
      id: 'loratadine_10',
      name: 'Loratadine 10mg',
      description: 'Non-drowsy allergy',
      imageUrl:
          'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=800',
      price: 9.25,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: kPaper,
      appBar: AppBar(
        backgroundColor: kBlush,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeShell()),
            );
          },
          icon: const Icon(Icons.arrow_back, color: kInk),
        ),
        title: Text('Pharmacy', style: theme.textTheme.titleLarge),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Consumer<CartProvider>(
              builder: (context, cart, _) {
                return CartBadge(
                  count: cart.totalQty,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pushNamed('/cart'),
                    icon: const Icon(Icons.shopping_cart_outlined),
                    color: kInk,
                    tooltip: 'Cart',
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                Text(
                  'Commonly Used',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Consumer<CartProvider>(
              builder: (context, cart, _) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    final qty = cart.quantityFor(product.id);

                    return ProductCard(
                      product: product,
                      qty: qty,
                      onAdd: () async {
                        try {
                          await cart.addProduct(product);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart'),
                                backgroundColor: Colors.green.shade600,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red.shade400,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      onIncrement: () async {
                        try {
                          await cart.increment(product.id);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red.shade400,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      onDecrement: () async {
                        try {
                          await cart.decrement(product.id);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red.shade400,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
