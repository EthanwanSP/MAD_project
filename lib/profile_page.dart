import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_bottom_nav.dart';
import 'home_shell.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.showBottomNav = true,
  });

  final bool showBottomNav;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
                  Text('Profile', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your account settings',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('John Doe', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text('john.doe@email.com', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 2),
                            Text('Member since Jan 2024', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: kBlush,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit_outlined, size: 16, color: kInk),
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
                      _SectionRow(icon: Icons.favorite_border, label: 'Medical Records'),
                      _DividerRow(),
                      _SectionRow(icon: Icons.receipt_long_outlined, label: 'Prescriptions'),
                      _DividerRow(),
                      _SectionRow(icon: Icons.person_outline, label: 'Personal Info'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle(title: 'App Settings'),
                  const SizedBox(height: 10),
                  const _SectionCard(
                    children: [
                      _SectionRow(icon: Icons.notifications_none_outlined, label: 'Notifications'),
                      _DividerRow(),
                      _SectionRow(icon: Icons.lock_outline, label: 'Privacy & Security'),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {},
                      child: const Text('Log out'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
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
        selectedIndex: 3,
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
