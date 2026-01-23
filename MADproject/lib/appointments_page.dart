import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_shell.dart';
import 'login_page.dart';
import 'services/firestore_service.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final FirestoreService _firestoreService = FirestoreService();

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'No date';
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} $hour:$minute $suffix';
  }

  void _redirectToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _showAddAppointmentSheet(String uid) async {
    final titleController = TextEditingController();
    DateTime? selectedDateTime;
    String status = 'booked';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add appointment', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title (e.g. Dental checkup)',
                      prefixIcon: Icon(Icons.medical_services_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date == null) return;
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time == null) return;
                      setState(() {
                        selectedDateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    },
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      selectedDateTime == null
                          ? 'Pick date & time'
                          : selectedDateTime!.toLocal().toString(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    items: const [
                      DropdownMenuItem(value: 'booked', child: Text('Booked')),
                      DropdownMenuItem(value: 'completed', child: Text('Completed')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => status = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Status',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final title = titleController.text.trim();
                        if (title.isEmpty || selectedDateTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter title and date/time.')),
                          );
                          return;
                        }
                        await _firestoreService.addAppointment(
                          uid: uid,
                          title: title,
                          dateTime: selectedDateTime!,
                          status: status,
                        );
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    titleController.dispose();
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
                            Text('My Appointments', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your healthcare bookings',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddAppointmentSheet(user.uid),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Your appointments', style: Theme.of(context).textTheme.titleMedium),
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
                    child: Text('Could not load appointments.'),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                              'No appointments yet. Tap Add to create one.',
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
                  children: docs.map((doc) {
                    final data = doc.data();
                    final title = (data['title'] ?? '') as String;
                    final status = (data['status'] ?? 'booked') as String;
                    final timestamp = data['datetime'] as Timestamp?;
                    final dateText = _formatDateTime(timestamp?.toDate());
                    return Dismissible(
                      key: ValueKey(doc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.centerRight,
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        _firestoreService.deleteAppointment(
                          uid: user.uid,
                          appointmentId: doc.id,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kPaper,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: kInk.withOpacity(0.08)),
                          boxShadow: [
                            BoxShadow(
                              color: kInk.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: kPeach.withOpacity(0.35),
                              child:
                                  const Icon(Icons.event_available_outlined, color: kInk, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text(dateText, style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: kBlush.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child:
                                      Text(status, style: Theme.of(context).textTheme.bodySmall),
                                ),
                                const SizedBox(height: 6),
                                if (status != 'cancelled')
                                  TextButton(
                                    onPressed: () {
                                      _firestoreService.deleteAppointment(
                                        uid: user.uid,
                                        appointmentId: doc.id,
                                      );
                                    },
                                    child: const Text('Cancel'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
