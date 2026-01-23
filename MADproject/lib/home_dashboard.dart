import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'login_page.dart';
import 'services/firestore_service.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final FirestoreService _firestoreService = FirestoreService();

  void _redirectToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'No date';
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} $hour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _redirectToLogin());
      return const SizedBox.shrink();
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kPaper,kPeach,kBlush,kPaper],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: kInk,
                  child: const Icon(Icons.person, color: kInk),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome in, Amelia!', style: Theme.of(context).textTheme.titleMedium),
                    Text('Your health, streamlined', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPaper,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kInk.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestoreService.streamAppointments(user.uid),
                builder: (context, snapshot) {
                  String label = 'No upcoming appointments';
                  if (snapshot.hasData) {
                    final docs = snapshot.data!.docs;
                    final now = DateTime.now();
                    final next = docs.map((doc) {
                      final data = doc.data();
                      if (data['status'] == 'cancelled') return null;
                      final timestamp = data['datetime'] as Timestamp?;
                      if (timestamp == null) return null;
                      final date = timestamp.toDate();
                      if (date.isBefore(now)) return null;
                      return {
                        'title': (data['title'] ?? '') as String,
                        'date': date,
                      };
                    }).whereType<Map<String, dynamic>>().toList()
                      ..sort((a, b) =>
                          (a['date'] as DateTime).compareTo(b['date'] as DateTime));
                    if (next.isNotEmpty) {
                      final item = next.first;
                      label =
                          '${item['title']} - ${_formatDateTime(item['date'] as DateTime)}';
                    }
                  }
                  return Row(
                    children: [
                      const Icon(Icons.health_and_safety_outlined, size: 32, color: kInk),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final crossAxisCount = maxWidth >= 1100
                    ? 4
                    : maxWidth >= 800
                        ? 3
                        : 2;
                final childAspectRatio = maxWidth >= 1100 ? 2.6 : 2.0;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: childAspectRatio,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ActionTile(
                      icon: Icons.assignment_outlined,
                      label: 'Appointments',
                      onTap: () => Navigator.of(context).pushNamed('/appointments'),
                    ),
                    ActionTile(
                      icon: Icons.storefront_outlined,
                      label: 'Online Shop',
                      onTap: () => Navigator.of(context).pushNamed('/shop'),
                    ),
                    ActionTile(
                      icon: Icons.confirmation_number_outlined,
                      label: 'Clinic Queue',
                      onTap: () => Navigator.of(context).pushNamed('/queue'),
                    ),
                    ActionTile(
                      icon: Icons.calendar_month_outlined,
                      label: 'Calendar',
                      onTap: () => Navigator.of(context).pushNamed('/calendar'),
                    ),
                    ActionTile(
                      icon: Icons.video_camera_front_outlined,
                      label: 'Tele Consult',
                      onTap: () => Navigator.of(context).pushNamed('/teleconsult'),
                    ),
                    ActionTile(
                      icon: Icons.map_outlined,
                      label: 'Nearest Hospitals',
                      onTap: () => Navigator.of(context).pushNamed('/hospitals'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            Text('Today', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestoreService.streamAppointments(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    'Could not load today\'s appointments.',
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                final now = DateTime.now();
                final todayItems = docs.where((doc) {
                  final data = doc.data();
                  if (data['status'] == 'cancelled') return false;
                  final timestamp = data['datetime'] as Timestamp?;
                  if (timestamp == null) return false;
                  return _isSameDay(timestamp.toDate(), now);
                }).toList();
                if (todayItems.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kPaper,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: kInk.withOpacity(0.08)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: kPeach.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.event_busy, color: kInk),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No appointments today.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: kInk.withOpacity(0.7),
                                ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: todayItems.map((doc) {
                    final data = doc.data();
                    final title = (data['title'] ?? '') as String;
                    final timestamp = data['datetime'] as Timestamp?;
                    final dateText = _formatDateTime(timestamp?.toDate());
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kPaper,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kInk.withOpacity(0.08)),
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
                            child: const Icon(Icons.event_available_outlined, color: kInk),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text(dateText, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ActionTile extends StatefulWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  State<ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<ActionTile> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: kPaper,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${widget.label} opened')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: kPeach.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(widget.icon, color: kInk, size: 35),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
