import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_bottom_nav.dart';
import 'home_shell.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({
    super.key,
    this.showBottomNav = true,
  });

  final bool showBottomNav;

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
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
                  Text('My Appointments', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your healthcare bookings',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Upcoming (3)', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 12),
            const AppointmentCard(
              name: 'Dr. Sarah Johnson',
              specialty: 'General Practitioner',
              date: 'Jan 22, 2026',
              time: '10:00 AM',
              location: 'MediConnect Clinic - Main',
            ),
            const AppointmentCard(
              name: 'Dr. Michael Chen',
              specialty: 'Dentist',
              date: 'Jan 25, 2026',
              time: '2:30 PM',
              location: 'MediConnect Dental Center',
            ),
            const AppointmentCard(
              name: 'Dr. Emily Rodriguez',
              specialty: 'Dermatologist',
              date: 'Feb 2, 2026',
              time: '9:15 AM',
              location: 'MediConnect Specialist Clinic',
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
        selectedIndex: 1,
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

class AppointmentCard extends StatefulWidget {
  const AppointmentCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.date,
    required this.time,
    required this.location,
  });

  final String name;
  final String specialty;
  final String date;
  final String time;
  final String location;

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPaper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kInk.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: kInk.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: kPeach.withOpacity(0.35),
                child: const Icon(Icons.medical_services_outlined, color: kInk, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name, style: Theme.of(context).textTheme.titleMedium),
                    Text(widget.specialty, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.event_outlined, text: widget.date),
          _InfoRow(icon: Icons.schedule_outlined, text: widget.time),
          _InfoRow(icon: Icons.place_outlined, text: widget.location),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kBlush,
                    foregroundColor: kInk,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {},
                  child: const Text('Reschedule'),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {},
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: kInk.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
