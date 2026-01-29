import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_shell.dart';
import 'appointments_manager.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final AppointmentsManager _manager = AppointmentsManager();
  List<CalendarEvent> calendarEvents = [
    CalendarEvent(
      id: 'c1',
      title: 'Health check-up',
      date: 'Feb 14, 2026',
      time: '10:30 AM',
      location: 'MediConnect Clinic',
    ),
    CalendarEvent(
      id: 'c2',
      title: 'Tele consult follow-up',
      date: 'Feb 20, 2026',
      time: '7:00 PM',
      location: 'Video call',
    ),
    CalendarEvent(
      id: 'c3',
      title: 'Medication refill',
      date: 'Feb 28, 2026',
      time: 'All day',
      location: 'Pharmacy pickup',
    ),
  ];

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

  void _removeEvent(String id) {
    setState(() {
      calendarEvents.removeWhere((event) => event.id == id);
    });
  }

  String _generateEventId() {
    if (calendarEvents.isEmpty) return 'c1';
    final ids = calendarEvents
        .map((e) => int.tryParse(e.id.replaceAll('c', '')) ?? 0)
        .toList();
    final maxId = ids.reduce((a, b) => a > b ? a : b);
    return 'c${maxId + 1}';
  }

  void _showAddAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAppointmentToCalendarDialog(
        appointments: _manager.appointments,
        onAddToCalendar: (appointment) {
          setState(() {
            final newEvent = CalendarEvent(
              id: _generateEventId(),
              title: 'Appointment with ${appointment.name}',
              date: _formatDate(appointment.date),
              time: _formatTime(appointment.time),
              location: appointment.location,
            );
            calendarEvents.add(newEvent);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Appointment added to calendar'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPaper,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(top: 140), // Space for fixed header
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Upcoming (${calendarEvents.length})',
                        style: Theme.of(context).textTheme.titleMedium),
                    FilledButton.icon(
                      onPressed: _showAddAppointmentDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                      style: FilledButton.styleFrom(
                        backgroundColor: kPeach,
                        foregroundColor: kInk,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (calendarEvents.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 80, color: kInk.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No calendar events',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: kInk.withOpacity(0.5),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add appointments from your appointments list',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: kInk.withOpacity(0.5),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...calendarEvents.map((event) => _EventCard(
                      key: ValueKey(event.id),
                      event: event,
                      onComplete: () => _removeEvent(event.id),
                    )),
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
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const HomeShell()),
                          );
                        },
                        icon: const Icon(Icons.arrow_back, color: kInk),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Calendar',
                                style: Theme.of(context).textTheme.titleLarge),
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
          ),
        ],
      ),
    );
  }
}

// Calendar Event Model
class CalendarEvent {
  final String id;
  final String title;
  final String date;
  final String time;
  final String location;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
  });
}

// Add Appointment to Calendar Dialog
class AddAppointmentToCalendarDialog extends StatelessWidget {
  const AddAppointmentToCalendarDialog({
    super.key,
    required this.appointments,
    required this.onAddToCalendar,
  });

  final List<AppointmentData> appointments;
  final Function(AppointmentData) onAddToCalendar;

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(Icons.event_note, color: kPeach, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add to Calendar',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          'Select an appointment to add',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: kInk.withOpacity(0.6),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: kInk.withOpacity(0.1)),
            Expanded(
              child: appointments.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy,
                                size: 64, color: kInk.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'No appointments available',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: kInk.withOpacity(0.5),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Book an appointment first',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: kInk.withOpacity(0.5),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];
                        return InkWell(
                          onTap: () {
                            onAddToCalendar(appointment);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: kPaper,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: kInk.withOpacity(0.08)),
                              boxShadow: [
                                BoxShadow(
                                  color: kInk.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: kPeach.withOpacity(0.35),
                                  child: const Icon(Icons.person,
                                      color: kInk, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appointment.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_formatDate(appointment.date)} at ${_formatTime(appointment.time)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      Text(
                                        appointment.location,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: kInk.withOpacity(0.6),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.add_circle_outline,
                                    color: kPeach, size: 24),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Divider(height: 1, color: kInk.withOpacity(0.1)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    super.key,
    required this.event,
    required this.onComplete,
  });

  final CalendarEvent event;
  final VoidCallback onComplete;

  Future<void> _showCompleteDialog(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Mark as Complete'),
        content: Text(
          'Mark "${event.title}" as complete? This will remove it from your calendar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onComplete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Event marked as complete'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

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
          Row(
            children: [
              Expanded(
                child: Text(event.title,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.check_circle_outline,
                      color: Colors.green.shade600),
                  iconSize: 20,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  onPressed: () => _showCompleteDialog(context),
                  tooltip: 'Mark as complete',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _EventRow(icon: Icons.event_outlined, text: event.date),
          _EventRow(icon: Icons.schedule_outlined, text: event.time),
          _EventRow(icon: Icons.place_outlined, text: event.location),
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