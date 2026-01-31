import 'package:flutter/material.dart';

class AppointmentData {
  final String id;
  String name;
  String specialty;
  DateTime date;
  TimeOfDay time;
  String location;

  AppointmentData({
    required this.id,
    required this.name,
    required this.specialty,
    required this.date,
    required this.time,
    required this.location,
  });
}

class AppointmentsManager extends ChangeNotifier {
  static final AppointmentsManager _instance = AppointmentsManager._internal();
  factory AppointmentsManager() => _instance;
  AppointmentsManager._internal();

  final List<AppointmentData> _appointments = [
    AppointmentData(
      id: '1',
      name: 'Dr. Sarah Johnson',
      specialty: 'General Practitioner',
      date: DateTime(2026, 1, 22),
      time: const TimeOfDay(hour: 10, minute: 0),
      location: 'MediConnect Clinic - Main',
    ),
    AppointmentData(
      id: '2',
      name: 'Dr. Michael Chen',
      specialty: 'Dentist',
      date: DateTime(2026, 1, 25),
      time: const TimeOfDay(hour: 14, minute: 30),
      location: 'MediConnect Dental Center',
    ),
    AppointmentData(
      id: '3',
      name: 'Dr. Emily Rodriguez',
      specialty: 'Dermatologist',
      date: DateTime(2026, 2, 2),
      time: const TimeOfDay(hour: 9, minute: 15),
      location: 'MediConnect Specialist Clinic',
    ),
  ];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppointmentData> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> addAppointment(AppointmentData appointment) async {
    final newAppointment = AppointmentData(
      id: generateId(),
      name: appointment.name,
      specialty: appointment.specialty,
      date: appointment.date,
      time: appointment.time,
      location: appointment.location,
    );
    _appointments.add(newAppointment);
    notifyListeners();
  }

  Future<void> cancelAppointment(String id) async {
    _appointments.removeWhere((apt) => apt.id == id);
    notifyListeners();
  }

  Future<void> updateAppointment(
    String id,
    DateTime newDate,
    TimeOfDay newTime,
  ) async {
    final index = _appointments.indexWhere((apt) => apt.id == id);
    if (index != -1) {
      _appointments[index].date = newDate;
      _appointments[index].time = newTime;
      notifyListeners();
    }
  }

  String generateId() {
    if (_appointments.isEmpty) return '1';
    final ids = _appointments.map((a) => int.tryParse(a.id) ?? 0).toList();
    final maxId = ids.reduce((a, b) => a > b ? a : b);
    return (maxId + 1).toString();
  }
}

// Available doctors
class Doctor {
  final String name;
  final String specialty;

  Doctor({required this.name, required this.specialty});
}

final List<Doctor> availableDoctors = [
  Doctor(name: 'Dr. Sarah Johnson', specialty: 'General Practitioner'),
  Doctor(name: 'Dr. Michael Chen', specialty: 'Dentist'),
  Doctor(name: 'Dr. Emily Rodriguez', specialty: 'Dermatologist'),
  Doctor(name: 'Dr. James Wilson', specialty: 'Cardiologist'),
  Doctor(name: 'Dr. Lisa Anderson', specialty: 'Pediatrician'),
  Doctor(name: 'Dr. Robert Taylor', specialty: 'Orthopedic Surgeon'),
];

// Available locations
final List<String> availableLocations = [
  'MediConnect Clinic - Main',
  'MediConnect Dental Center',
  'MediConnect Specialist Clinic',
  'MediConnect Heart Center',
  'MediConnect Children\'s Hospital',
  'MediConnect Orthopedic Center',
];
