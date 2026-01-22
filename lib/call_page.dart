import 'package:flutter/material.dart';

import 'app_bottom_nav.dart';
import 'app_theme.dart';
import 'home_shell.dart';

class CallPage extends StatelessWidget {
  const CallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: kPaper,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              const SizedBox(height: 12),
              Text('Calling now', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Dr. Aisha Patel',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text('Family Medicine', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 24),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: kBlush.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kInk.withOpacity(0.08)),
                ),
                child: Center(
                  child: Icon(Icons.videocam_outlined, size: 48, color: kInk.withOpacity(0.7)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CallAction(
                    icon: Icons.mic_off_outlined,
                    label: 'Mute',
                    onTap: () {},
                  ),
                  _CallAction(
                    icon: Icons.videocam_off_outlined,
                    label: 'Video',
                    onTap: () {},
                  ),
                  _CallAction(
                    icon: Icons.chat_bubble_outline,
                    label: 'Message',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: kPaper,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('End call'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 0,
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

class _CallAction extends StatelessWidget {
  const _CallAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: kPaper,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kInk.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: kInk),
            const SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
