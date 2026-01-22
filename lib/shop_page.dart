import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_bottom_nav.dart';
import 'home_shell.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({
    super.key,
    this.showBottomNav = true,
  });

  final bool showBottomNav;

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  @override
  Widget build(BuildContext context) {
    final content = Container(
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
                  Text('Shop', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Browse health essentials and services',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Recommended', style: Theme.of(context).textTheme.titleMedium),
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
              children: const [
                _ShopCard(
                  title: 'Wellness Pack',
                  subtitle: 'Starter vitamins',
                  price: '\$29',
                ),
                _ShopCard(
                  title: 'Tele Consult',
                  subtitle: 'Anytime access',
                  price: '\$18',
                ),
                _ShopCard(
                  title: 'Lab Screening',
                  subtitle: 'Full panel',
                  price: '\$89',
                ),
                _ShopCard(
                  title: 'Skin Care',
                  subtitle: 'Derm-approved',
                  price: '\$25',
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (!widget.showBottomNav) {
      return content;
    }

    return Scaffold(
      body: content,
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 2,
        onDestinationSelected: (value) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomeShell(initialIndex: value)),
            (route) => false,
          );
        },
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.title,
    required this.subtitle,
    required this.price,
  });

  final String title;
  final String subtitle;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: kPeach.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: kInk),
          ),
          const Spacer(),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(price, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
