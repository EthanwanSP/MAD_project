import 'package:flutter/material.dart';

import 'app_theme.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  Widget build(BuildContext context) {
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
              child: Row(
                children: [
                  const Icon(Icons.health_and_safety_outlined, size: 32, color: kInk),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Next check-up: 14 Feb, 10:30 AM',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
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
            Text(
              'Appointments, queues, and delivery updates will appear here.',
              style: Theme.of(context).textTheme.bodySmall,
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
