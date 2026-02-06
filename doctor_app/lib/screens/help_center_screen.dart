import 'package:flutter/material.dart';

import '../app_theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPaper,
      appBar: AppBar(
        backgroundColor: kBlush,
        elevation: 0,
        title: const Text('Help center'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(
            'Frequently asked questions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _FaqCard(
            question: 'How do I reschedule an appointment?',
            answer:
                'Go to My Appointments, tap Reschedule, and pick a new date and time.',
          ),
          _FaqCard(
            question: 'Where can I see my queue number?',
            answer:
                'Open the Queue tab to view your current queue position and wait time.',
          ),
          _FaqCard(
            question: 'How do I update my health profile?',
            answer:
                'Open Profile ? Health profile ? Edit health info and save your updates.',
          ),
          _FaqCard(
            question: 'Can I store multiple addresses?',
            answer:
                'Yes. Add an address in Address book and select it at checkout.',
          ),
          const SizedBox(height: 24),
          Text(
            'Contact us',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.email_outlined,
            label: 'support@mediconnect.com',
          ),
          const SizedBox(height: 8),
          _ContactCard(
            icon: Icons.phone_outlined,
            label: '+1 (800) 555-0142',
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPaper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kInk.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: kInk.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(answer, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kPaper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kInk.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: kInk),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
