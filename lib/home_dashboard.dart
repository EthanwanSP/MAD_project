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
    final quickActions = [
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
      const ActionTile(
        icon: Icons.medication_outlined,
        label: 'Prescriptions',
      ),
      const ActionTile(
        icon: Icons.insert_chart_outlined,
        label: 'Reports',
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kBlush, kPaper],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.person, color: kInk),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hi, Amelia', style: Theme.of(context).textTheme.titleMedium),
                    Text('Your health, streamlined', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_scanner),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: ShapeDecoration(
                      color: kInk,
                      shape: const StadiumBorder(),
                    ),
                    child: const Center(
                      child: Text(
                        'Online',
                        style: TextStyle(color: kPaper, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    child: Center(
                      child: Text(
                        'Offline',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search doctors, services, or clinics',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: kInk.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
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
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: quickActions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return SizedBox(width: 150, child: quickActions[index]);
                },
              ),
            ),
            const SizedBox(height: 18),
            InkWell(
              onTap: () => Navigator.of(context).pushNamed('/appointments'),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text('Today', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_right, size: 18, color: kInk.withOpacity(0.6)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Appointments, queues, and delivery updates will appear here.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text('Upcoming', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            const UpcomingItem(
              title: 'Dr. Sarah Johnson',
              detail: 'Check-up - Feb 14, 10:30 AM',
            ),
            const UpcomingItem(
              title: 'Tele consult follow-up',
              detail: 'Video call - Feb 20, 7:00 PM',
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

class UpcomingItem extends StatelessWidget {
  const UpcomingItem({
    super.key,
    required this.title,
    required this.detail,
  });

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kInk.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: kBlush.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.event_available_outlined, color: kInk, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(detail, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTileState extends State<ActionTile> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
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
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: kBlush.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
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
