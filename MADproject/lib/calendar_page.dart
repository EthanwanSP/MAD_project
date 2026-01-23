import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_shell.dart';
import 'login_page.dart';
import 'services/firestore_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final FirestoreService _firestoreService = FirestoreService();

  void _redirectToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'No date';
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} $hour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _redirectToLogin());
      return const SizedBox.shrink();
    }

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
                            Text('Calendar', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text(
                              'Plan your check-ups and reminders',
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
              child: Text('Today', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestoreService.streamAppointments(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text('Could not load calendar.'),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                final now = DateTime.now();
                final todayItems = docs.where((doc) {
                  final data = doc.data();
                  if (data['status'] == 'cancelled') return false;
                  final timestamp = data['datetime'] as Timestamp?;
                  if (timestamp == null) return false;
                  return _isSameDay(timestamp.toDate(), now);
                }).toList();

                if (todayItems.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: kPaper,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: kInk.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: kPeach.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.event_busy, color: kInk),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No appointments today.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: kInk.withOpacity(0.7),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: todayItems.map((doc) {
                    final data = doc.data();
                    final title = (data['title'] ?? '') as String;
                    final timestamp = data['datetime'] as Timestamp?;
                    final dateText = _formatDateTime(timestamp?.toDate());
                    return _EventCard(
                      title: title,
                      date: dateText,
                      time: '',
                      location: '',
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Upcoming', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestoreService.streamAppointments(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text('Could not load calendar.'),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                final now = DateTime.now();
                final upcomingItems = docs.where((doc) {
                  final data = doc.data();
                  if (data['status'] == 'cancelled') return false;
                  final timestamp = data['datetime'] as Timestamp?;
                  if (timestamp == null) return false;
                  final date = timestamp.toDate();
                  return date.isAfter(DateTime(now.year, now.month, now.day, 23, 59));
                }).toList();

                if (upcomingItems.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: kPaper,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: kInk.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: kPeach.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.event_available_outlined, color: kInk),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No upcoming appointments.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: kInk.withOpacity(0.7),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: upcomingItems.map((doc) {
                    final data = doc.data();
                    final title = (data['title'] ?? '') as String;
                    final timestamp = data['datetime'] as Timestamp?;
                    final dateText = _formatDateTime(timestamp?.toDate());
                    return _EventCard(
                      title: title,
                      date: dateText,
                      time: '',
                      location: '',
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.title,
    required this.date,
    required this.time,
    required this.location,
  });

  final String title;
  final String date;
  final String time;
  final String location;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _EventRow(icon: Icons.event_outlined, text: date),
          if (time.isNotEmpty) _EventRow(icon: Icons.schedule_outlined, text: time),
          if (location.isNotEmpty) _EventRow(icon: Icons.place_outlined, text: location),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.icon, required this.text});

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
