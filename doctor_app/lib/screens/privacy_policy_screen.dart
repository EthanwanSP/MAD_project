import 'package:flutter/material.dart';

import '../app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPaper,
      appBar: AppBar(
        backgroundColor: kBlush,
        elevation: 0,
        title: const Text('Privacy policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Privacy policy', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'We respect your privacy and are committed to protecting your personal data.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'What we collect',
            body:
                'Contact details, account information, appointment history, and health profile data you choose to provide.',
          ),
          _Section(
            title: 'How we use data',
            body:
                'To provide appointment services, manage queues, and improve the overall care experience.',
          ),
          _Section(
            title: 'Sharing',
            body:
                'We do not sell your data. We only share it with care providers when needed for your appointments.',
          ),
          _Section(
            title: 'Your choices',
            body:
                'You can update or delete your information from your profile at any time.',
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
