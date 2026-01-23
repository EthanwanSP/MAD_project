import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_shell.dart';

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
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
                            Text('Clinic Queue', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text(
                              'Track your live queue number',
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
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: kPaper,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kInk.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: kInk.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: kPeach.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.confirmation_number_outlined, color: kInk, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your queue number', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text('A-17', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text('Estimated wait: 18 min', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Now serving', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            const _QueueStatusTile(label: 'A-12', status: 'In consultation'),
            const _QueueStatusTile(label: 'A-13', status: 'Ready soon'),
            const _QueueStatusTile(label: 'A-14', status: 'In consultation'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _QueueStatusTile extends StatelessWidget {
  const _QueueStatusTile({required this.label, required this.status});

  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kPaper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kInk.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Text(status, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
