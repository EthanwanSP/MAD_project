import 'package:flutter/material.dart';

import 'app_theme.dart';

class HospitalsPage extends StatefulWidget {
  const HospitalsPage({super.key});

  @override
  State<HospitalsPage> createState() => _HospitalsPageState();
}

class _HospitalsPageState extends State<HospitalsPage> {
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
                  Text('Nearest Hospitals', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Find care near your location',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: kPeach.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kInk.withOpacity(0.06)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map_outlined, size: 36, color: kInk),
                    const SizedBox(height: 8),
                    Text('Map preview', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text('Enable location to see nearby hospitals',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Nearby', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 10),
            const _HospitalCard(
              name: 'CityCare Medical Center',
              distance: '1.2 km',
              eta: '8 min drive',
            ),
            const _HospitalCard(
              name: 'Northside General Hospital',
              distance: '2.6 km',
              eta: '12 min drive',
            ),
            const _HospitalCard(
              name: 'Wellness Urgent Care',
              distance: '3.1 km',
              eta: '15 min drive',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  const _HospitalCard({
    required this.name,
    required this.distance,
    required this.eta,
  });

  final String name;
  final String distance;
  final String eta;

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
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: kPeach.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_hospital_outlined, color: kInk, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('$distance • $eta', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18),
        ],
      ),
    );
  }
}
