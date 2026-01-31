import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_shell.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _formatMemberSince(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Member since -';
    }
    final date = timestamp.toDate();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return 'Member since ${months[date.month - 1]} ${date.year}';
  }

  String _formatPurchaseDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userStream = user == null
        ? null
        : FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots();

    final purchasesStream = user == null
        ? null
        : FirebaseFirestore.instance
            .collection('purchases')
            .where('userId', isEqualTo: user.uid)
            .orderBy('purchaseDate', descending: true)
            .snapshots();
    return Container(
      color: kPaper,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(top: 140), // Space for fixed header
            children: [
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: kPeach.withOpacity(0.35),
                          child: const Icon(Icons.person, color: kInk, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: StreamBuilder<
                              DocumentSnapshot<Map<String, dynamic>>>(
                            stream: userStream,
                            builder: (context, snapshot) {
                              final data = snapshot.data?.data() ?? {};
                              final name = (data['name'] as String?) ??
                                  (user?.displayName ?? 'User');
                              final email = (data['email'] as String?) ??
                                  (user?.email ?? '');
                              final createdAt =
                                  data['createdAt'] as Timestamp?;
                              final memberSince = _formatMemberSince(createdAt);

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Loading...',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    const SizedBox(height: 2),
                                    Text(
                                      '',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    memberSince,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: kBlush,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: kInk,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _StatTile(value: '12', label: 'Appointments'),
                        _StatTile(value: '5', label: 'Saved Doctors'),
                        _StatTile(value: '3', label: 'Prescriptions'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionTitle(title: 'Health Profile'),
                    const SizedBox(height: 10),
                    const _SectionCard(
                      children: [
                        _SectionRow(
                          icon: Icons.favorite_border,
                          label: 'Medical Records',
                        ),
                        _DividerRow(),
                        _SectionRow(
                          icon: Icons.receipt_long_outlined,
                          label: 'Prescriptions',
                        ),
                        _DividerRow(),
                        _SectionRow(
                          icon: Icons.person_outline,
                          label: 'Personal Info',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _SectionTitle(title: 'Purchase History'),
                    const SizedBox(height: 10),
                    _SectionCard(
                      children: [
                        StreamBuilder<
                            QuerySnapshot<Map<String, dynamic>>>(
                          stream: purchasesStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const ListTile(
                                leading: Icon(Icons.receipt_long_outlined),
                                title: Text('Loading purchases...'),
                              );
                            }

                            if (snapshot.hasError) {
                              return const ListTile(
                                leading: Icon(Icons.error_outline),
                                title: Text('Unable to load purchases'),
                              );
                            }

                            final purchases = snapshot.data?.docs ?? [];
                            if (purchases.isEmpty) {
                              return const ListTile(
                                leading: Icon(Icons.shopping_bag_outlined),
                                title: Text('No purchases yet'),
                                subtitle:
                                    Text('Shop items will appear here'),
                              );
                            }

                            return Column(
                              children: purchases.take(5).map((doc) {
                                final data = doc.data();
                                final itemName =
                                    (data['itemName'] as String?) ?? 'Item';
                                final price = data['price'];
                                final quantity =
                                    (data['quantity'] as int?) ?? 1;
                                final purchaseDate = _formatPurchaseDate(
                                  data['purchaseDate'] as Timestamp?,
                                );
                                return ListTile(
                                  leading: const Icon(
                                      Icons.shopping_bag_outlined),
                                  title: Text(itemName),
                                  subtitle:
                                      Text('Qty $quantity - $purchaseDate'),
                                  trailing: Text(
                                    price is num
                                        ? '\$${price.toStringAsFixed(2)}'
                                        : '',
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _SectionTitle(title: 'App Settings'),
                    const SizedBox(height: 10),
                    const _SectionCard(
                      children: [
                        _SectionRow(
                          icon: Icons.notifications_none_outlined,
                          label: 'Notifications',
                        ),
                        _DividerRow(),
                        _SectionRow(
                          icon: Icons.lock_outline,
                          label: 'Privacy & Security',
                        ),
                        _DividerRow(),
                        _SectionRow(icon: Icons.help_outline, label: 'Support'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: kInk,
                          foregroundColor: kPaper,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                        child: const Text('Log out'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
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
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
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
                            Text(
                              'Profile',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your account settings',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
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

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: kPaper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kInk.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: kInk.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: kPeach.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: kInk),
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () {},
    );
  }
}

class _DividerRow extends StatelessWidget {
  const _DividerRow();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: kInk.withOpacity(0.06));
  }
}


