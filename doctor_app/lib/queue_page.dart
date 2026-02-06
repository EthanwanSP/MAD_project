import 'package:flutter/material.dart';
import 'dart:math';

import 'app_theme.dart';
import 'appointments_manager.dart';
import 'home_shell.dart';

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});

  @override
  State<QueuePage> createState() => _QueuePageState();
}

const int _avgMinutesPerAppointment = 10;

class _QueuePageState extends State<QueuePage> {
  final AppointmentsManager _manager = AppointmentsManager();

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onAppointmentsChanged);
  }

  @override
  void dispose() {
    _manager.removeListener(_onAppointmentsChanged);
    super.dispose();
  }

  void _onAppointmentsChanged() {
    setState(() {});
  }

  AppointmentData? _nextAppointment(List<AppointmentData> appointments) {
    if (appointments.isEmpty) return null;
    final now = DateTime.now();
    final sorted = [...appointments]..sort((a, b) {
      final aDateTime = DateTime(
        a.date.year,
        a.date.month,
        a.date.day,
        a.time.hour,
        a.time.minute,
      );
      final bDateTime = DateTime(
        b.date.year,
        b.date.month,
        b.date.day,
        b.time.hour,
        b.time.minute,
      );
      return aDateTime.compareTo(bDateTime);
    });
    return sorted.firstWhere(
      (appt) {
        final dateTime = DateTime(
          appt.date.year,
          appt.date.month,
          appt.date.day,
          appt.time.hour,
          appt.time.minute,
        );
        return !dateTime.isBefore(now);
      },
      orElse: () => sorted.first,
    );
  }

  int _randomPeopleAhead() => Random().nextInt(6);
  int _randomWaitMinutes() => Random().nextInt(7) * 5;

  @override
  Widget build(BuildContext context) {
    final appointment = _nextAppointment(_manager.appointments);
    return Container(
      color: kPaper,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(top: 140), // Space for fixed header
            children: [
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: appointment == null
                    ? _EmptyQueueCard()
                    : _QueueCard(
                        appointment: appointment,
                        peopleAhead: _randomPeopleAhead(),
                        waitMinutes: _randomWaitMinutes(),
                      ),
              ),
              const SizedBox(height: 16),
              if (appointment != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Queue details',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 8),
                _QueueStatusTile(
                  label: 'Service',
                  status: appointment.name,
                ),
                _QueueStatusTile(
                  label: 'Clinic',
                  status: appointment.location,
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
          // Fixed header at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 22),
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
          ),
        ],
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({
    required this.appointment,
    required this.peopleAhead,
    required this.waitMinutes,
  });

  final AppointmentData appointment;
  final int peopleAhead;
  final int waitMinutes;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: const Icon(Icons.confirmation_number_outlined,
                color: kInk, size: 26),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your queue number',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                appointment.queueNumber != null
                    ? 'Q-${appointment.queueNumber}'
                    : '--',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'People ahead: $peopleAhead',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                'Estimated wait: $waitMinutes min',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyQueueCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kPaper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kInk.withOpacity(0.08)),
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
            child: const Icon(Icons.confirmation_number_outlined,
                color: kInk, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No active queue',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Book an appointment to get a queue number',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
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
