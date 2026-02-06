import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'app_theme.dart';
import 'appointments_manager.dart';
import 'auth_session.dart';
import 'app_colors.dart';
import 'services/booking_service.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final TextEditingController _homesearch = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const double _pad = 16;
  static const double _padSm = 12;
  static const double _padLg = 24;
  static const double _cardRadius = 16;
  static const double _tileRadius = 14;

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
    final String displayName = kIsWeb
        ? (AuthSession.displayName ?? 'User')
        : (FirebaseAuth.instance.currentUser?.displayName ?? 'User');

    return Container(
      color: kPaper,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(_pad, 176, _pad, _padLg),
            children: [
              _SectionHeader(
                title: 'Quick Actions',
                subtitle: 'What would you like to do today?',
              ),
              const SizedBox(height: _padSm),
              _QuickActionsGrid(
                tiles: [
                  ActionTile(
                    icon: Icons.assignment_outlined,
                    label: 'Appointments',
                    iconColor: AppColors.tintBlue,
                    onTap: () =>
                        Navigator.of(context).pushNamed('/appointments'),
                  ),
                  ActionTile(
                    icon: Icons.storefront_outlined,
                    label: 'Pharmacy',
                    iconColor: AppColors.tintGreen,
                    onTap: () => Navigator.of(context).pushNamed('/shop'),
                  ),
                  ActionTile(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Queue',
                    iconColor: AppColors.tintAmber,
                    onTap: () => Navigator.of(context).pushNamed('/queue'),
                  ),
                  ActionTile(
                    icon: Icons.calendar_month_outlined,
                    label: 'Calendar',
                    iconColor: AppColors.tintPurple,
                    onTap: () => Navigator.of(context).pushNamed('/calendar'),
                  ),
                  ActionTile(
                    icon: Icons.video_camera_front_outlined,
                    label: 'Tele-consult',
                    iconColor: AppColors.tintRose,
                    onTap: () => Navigator.of(context).pushNamed('/teleconsult'),
                  ),
                  ActionTile(
                    icon: Icons.map_outlined,
                    label: 'Hospitals',
                    iconColor: AppColors.tintTeal,
                    onTap: () => Navigator.of(context).pushNamed('/hospitals'),
                  ),
                ],
              ),
              const SizedBox(height: _padLg),
              _SectionHeader(
                title: 'Your health, Our priority!',
              ),
              const SizedBox(height: _padSm),
              _HealthCarousel(
                controller: _pageController,
                currentPage: _currentPage,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 36, 20, 14),
              decoration: const BoxDecoration(
                color: kBlush,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: _HomeHeaderCard(
                displayName: displayName,
                onProfileTap: () =>
                    Navigator.pushNamed(context, '/profilePage'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeaderCard extends StatelessWidget {
  const _HomeHeaderCard({
    required this.displayName,
    required this.onProfileTap,
  });

  final String displayName;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _HomeDashboardState._pad,
        vertical: 8,
      ),
      decoration: const BoxDecoration(
        color: kBlush,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(24),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: const Icon(Icons.person, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: _HomeDashboardState._padSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: -0.2,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'How are you feeling today?',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
          Lottie.network(
            'https://lottie.host/4c68f94b-88dd-40cb-a7b8-f1f4d952e1ca/gsZRXU1w06.json',
            height: 56,
            width: 56,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: -0.2,
                color: AppColors.textPrimary,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.05,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }
}

class _HealthCarousel extends StatelessWidget {
  const _HealthCarousel({
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
  });

  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView(
            controller: controller,
            onPageChanged: onPageChanged,
            children: const [
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
                    'https://images.hindustantimes.com/rf/image_size_960x540/HT/p2/2020/06/30/Pictures/_59e23780-baa1-11ea-b411-fb55c265b659.jpg',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: currentPage == index ? 18 : 6,
              decoration: BoxDecoration(
                color: currentPage == index
                    ? AppColors.primary
                    : AppColors.textSecondary.withOpacity(0.35),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PromotionSlide extends StatelessWidget {
  const PromotionSlide({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ],
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
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_HomeDashboardState._tileRadius),
        elevation: 0,
        child: InkWell(
          borderRadius:
              BorderRadius.circular(_HomeDashboardState._tileRadius),
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
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
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: kInk, size: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                        color: AppColors.textPrimary,
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
  bool _isSubmitting = false;
  final List<TimeOfDay> _timeSlots =
      List.generate(9, (index) => TimeOfDay(hour: 9 + index, minute: 0));

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

  String _formatTime24(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
    final TimeOfDay? picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: _timeSlots.map((slot) {
              return InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => Navigator.of(context).pop(slot),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: kPeach.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: kInk.withOpacity(0.15)),
                  ),
                  child: Text(
                    _formatTime(slot),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: kInk,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _bookAppointment() async {
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final chosenDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );
    if (chosenDate.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please choose today or a future date'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final bookingService = BookingService();
    final manager = AppointmentsManager();
    final newAppointment = AppointmentData(
      id: '',
      name: _selectedDoctor!.name,
      specialty: _selectedDoctor!.specialty,
      date: _selectedDate!,
      time: _selectedTime!,
      location: _selectedLocation!,
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await bookingService.createBookingAndAssignQueue(
        appointment: newAppointment,
        clinicId: _selectedLocation!,
        serviceId: _selectedDoctor!.name,
        bookingDate: _selectedDate!,
        time: _selectedTime!,
        slotId: _formatTime24(_selectedTime!),
      );
      if (kIsWeb) {
        await manager.refreshWeb();
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Appointment booked with ${_selectedDoctor!.name} on ${_formatDate(_selectedDate!)} at ${_formatTime(_selectedTime!)}. Your queue number is ${result.queueNumber}.'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to book appointment: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
                      onPressed: _isSubmitting ? null : _bookAppointment,
                      style: FilledButton.styleFrom(
                        backgroundColor: kPeach,
                        foregroundColor: kInk,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Book',
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
