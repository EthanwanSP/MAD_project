import 'package:flutter/material.dart';

import '../app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPaper,
      appBar: AppBar(
        backgroundColor: kBlush,
        elevation: 0,
        title: const Text('Terms of service'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Terms of service', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'By using MediConnect, you agree to the following terms and conditions.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Use of the service',
            body:
                'You are responsible for keeping your account secure and for all activity on your account.',
          ),
          _Section(
            title: 'Appointments',
            body:
                'Appointment availability is subject to provider schedules. Please arrive on time.',
          ),
          _Section(
            title: 'Payments',
            body:
                'All payments are processed securely. Refunds are subject to clinic policy.',
          ),
          _Section(
            title: 'Changes',
            body:
                'We may update these terms from time to time. Continued use indicates acceptance of updates.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(body, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
