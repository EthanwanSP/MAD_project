import 'package:flutter/material.dart';

import 'app_theme.dart';

class VideoCallPage extends StatelessWidget {
  const VideoCallPage({super.key, required this.doctorName});

  final String doctorName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF101418),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2026),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Icon(Icons.videocam, size: 96, color: Colors.white.withOpacity(0.4)),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                top: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    doctorName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Positioned(
                right: 24,
                top: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Google Meet',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
              Positioned(
                right: 24,
                bottom: 140,
                child: Container(
                  height: 120,
                  width: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A323B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Icon(Icons.person, color: Colors.white.withOpacity(0.6)),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 28,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CallControl(
                      icon: Icons.mic_off_outlined,
                      label: 'Mute',
                      onPressed: () {},
                    ),
                    const SizedBox(width: 12),
                    _CallControl(
                      icon: Icons.videocam_off_outlined,
                      label: 'Camera',
                      onPressed: () {},
                    ),
                    const SizedBox(width: 12),
                    _CallControl(
                      icon: Icons.screen_share_outlined,
                      label: 'Share',
                      onPressed: () {},
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.call_end),
                      label: const Text('End'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallControl extends StatelessWidget {
  const _CallControl({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
