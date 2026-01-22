import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_shell.dart';

class TeleConsultPage extends StatefulWidget {
  const TeleConsultPage({super.key});

  @override
  State<TeleConsultPage> createState() => _TeleConsultPageState();
}

class _TeleConsultPageState extends State<TeleConsultPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                            Text('Tele Consult', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text(
                              'Chat or video call with a doctor',
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Available now', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 12),
            const _ConsultCard(
              name: 'Dr. Aisha Patel',
              specialty: 'Family Medicine',
              status: 'Online',
            ),
            const _ConsultCard(
              name: 'Dr. David Lim',
              specialty: 'Pediatrics',
              status: 'Online',
            ),
            const _ConsultCard(
              name: 'Dr. Clara Ng',
              specialty: 'Dermatology',
              status: 'Available in 10 min',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ConsultCard extends StatelessWidget {
  const _ConsultCard({
    required this.name,
    required this.specialty,
    required this.status,
  });

  final String name;
  final String specialty;
  final String status;

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
            color: kInk.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: kPeach.withOpacity(0.35),
            child: const Icon(Icons.person, color: kInk),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                Text(specialty, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(status, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: kInk,
              foregroundColor: kPaper,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {},
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}
