import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'app_theme.dart';
import 'appointments_manager.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final TextEditingController _homesearch = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _homesearch.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => const BookAppointmentDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 255, 217, 196),
            const Color.fromARGB(255, 255, 245, 248)
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                Lottie.network(
                  'https://lottie.host/4c68f94b-88dd-40cb-a7b8-f1f4d952e1ca/gsZRXU1w06.json',
                  height: 70,
                  width: 70,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome in,',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Jon Doe!',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/profilePage');
                  },
                  iconSize: 30,
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                  icon: const Icon(Icons.person),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(19),
              ),
              child: TextField(
                controller: _homesearch,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  hintText: 'How can we help you today?',
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                FilledButton(
                  onPressed: _showBookingDialog,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 123, 0),
                    foregroundColor: Colors.black,
                    minimumSize: Size(180, 55),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 25,
                      ),
                      Text('Book Appointment',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: kPaper,
                    foregroundColor: kInk,
                    minimumSize: Size(180, 55),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timelapse,
                        size: 25,
                      ),
                      Text('Schedule later',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Quick services',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ActionTile(
                    icon: Icons.assignment_outlined,
                    label: 'My Appointments',
                    iconColor: Colors.blue,
                    onTap: () => Navigator.of(context).pushNamed('/appointments'),
                  ),
                  const SizedBox(width: 10),
                  ActionTile(
                    icon: Icons.storefront_outlined,
                    label: 'Pharmacy',
                    iconColor: Colors.green,
                    onTap: () => Navigator.of(context).pushNamed('/shop'),
                  ),
                  const SizedBox(width: 10),
                  ActionTile(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Queue No.',
                    iconColor: Colors.orange,
                    onTap: () => Navigator.of(context).pushNamed('/queue'),
                  ),
                  const SizedBox(width: 10),
                  ActionTile(
                    icon: Icons.calendar_month_outlined,
                    label: 'Calendar',
                    iconColor: Colors.purple,
                    onTap: () => Navigator.of(context).pushNamed('/calendar'),
                  ),
                  const SizedBox(width: 10),
                  ActionTile(
                    icon: Icons.video_camera_front_outlined,
                    label: 'Tele-consult',
                    iconColor: Colors.red,
                    onTap: () => Navigator.of(context).pushNamed('/teleconsult'),
                  ),
                  const SizedBox(width: 10),
                  ActionTile(
                    icon: Icons.map_outlined,
                    label: 'Hospitals nearby',
                    iconColor: Colors.teal,
                    onTap: () => Navigator.of(context).pushNamed('/hospitals'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Text('Your health, Our priority!',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            // PageView with smooth sliding
            SizedBox(
              height: 180,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  PromotionSlide(
                    imageUrl:
                        'https://northshorehealth.org/wp-content/uploads/Hydration-Blog-980x551-1.webp',
                  ),
                  PromotionSlide(
                    imageUrl:
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRb_j-hJDHqXw7gefhLpUgSVkSzRGcFxxnMqg&s',
                  ),
                  PromotionSlide(
                    imageUrl:
                        'https://graciousquotes.com/wp-content/uploads/2022/11/To-enjoy-the-glow-of-good-health-you-must-exercise.-Gene-Tunney.jpg',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? kInk : kInk.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

// Book Appointment Dialog
class BookAppointmentDialog extends StatefulWidget {
  const BookAppointmentDialog({super.key});

  @override
  State<BookAppointmentDialog> createState() => _BookAppointmentDialogState();
}

class _BookAppointmentDialogState extends State<BookAppointmentDialog> {
  Doctor? _selectedDoctor;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedLocation;

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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kPeach,
              onPrimary: kInk,
              onSurface: kInk,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kPeach,
              onPrimary: kInk,
              onSurface: kInk,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _bookAppointment() {
    if (_selectedDoctor == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final manager = AppointmentsManager();
    final newAppointment = AppointmentData(
      id: manager.generateId(),
      name: _selectedDoctor!.name,
      specialty: _selectedDoctor!.specialty,
      date: _selectedDate!,
      time: _selectedTime!,
      location: _selectedLocation!,
    );

    manager.addAppointment(newAppointment);

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Appointment booked with ${_selectedDoctor!.name} on ${_formatDate(_selectedDate!)} at ${_formatTime(_selectedTime!)}'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: BoxConstraints(maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: kPeach, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Book Appointment',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Doctor Dropdown
              Text('Select Doctor',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: kInk.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Doctor>(
                    isExpanded: true,
                    value: _selectedDoctor,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Choose a doctor'),
                    ),
                    borderRadius: BorderRadius.circular(14),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    items: availableDoctors.map((doctor) {
                      return DropdownMenuItem<Doctor>(
                        value: doctor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(doctor.name,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(doctor.specialty,
                                style: TextStyle(
                                    fontSize: 12, color: kInk.withOpacity(0.6))),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (doctor) {
                      setState(() {
                        _selectedDoctor = doctor;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Date Selection
              Text('Select Date', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: kInk.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, color: kPeach),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Choose a date'
                            : _formatDate(_selectedDate!),
                        style: TextStyle(
                          color: _selectedDate == null
                              ? kInk.withOpacity(0.5)
                              : kInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Time Selection
              Text('Select Time', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectTime,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: kInk.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: kPeach),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime == null
                            ? 'Choose a time'
                            : _formatTime(_selectedTime!),
                        style: TextStyle(
                          color: _selectedTime == null
                              ? kInk.withOpacity(0.5)
                              : kInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Location Dropdown
              Text('Select Location',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: kInk.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedLocation,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Choose a location'),
                    ),
                    borderRadius: BorderRadius.circular(14),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    items: availableLocations.map((location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (location) {
                      setState(() {
                        _selectedLocation = location;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _bookAppointment,
                      style: FilledButton.styleFrom(
                        backgroundColor: kPeach,
                        foregroundColor: kInk,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Book',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simplified Promotion Slide Widget - Only Image
class PromotionSlide extends StatelessWidget {
  const PromotionSlide({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class ActionTile extends StatefulWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  State<ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<ActionTile> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Material(
        color: kPaper,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.label} opened')),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 28),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}