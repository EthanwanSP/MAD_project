import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:doctor_app/firebase_options.dart';
import 'auth_session.dart';

class AppointmentData {
  final String id;
  String name;
  String specialty;
  DateTime date;
  TimeOfDay time;
  String location;
  String status;
  String? userId;
  String? doctorId;
  String? notes;

  AppointmentData({
    required this.id,
    required this.name,
    required this.specialty,
    required this.date,
    required this.time,
    required this.location,
    this.status = 'upcoming',
    this.userId,
    this.doctorId,
    this.notes,
  });

  factory AppointmentData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final Timestamp? dateStamp = data['appointmentDate'] as Timestamp?;
    final Timestamp? dateTimeStamp = data['appointmentDateTime'] as Timestamp?;
    final DateTime date =
        (dateStamp ?? dateTimeStamp)?.toDate() ?? DateTime.now();
    final String timeRaw = (data['appointmentTime'] as String?) ?? '09:00';
    final TimeOfDay time = _parseTime(timeRaw);

    return AppointmentData(
      id: doc.id,
      name: (data['doctorName'] as String?) ?? (data['name'] as String?) ?? '',
      specialty: (data['doctorSpecialty'] as String?) ??
          (data['specialty'] as String?) ??
          '',
      date: DateTime(date.year, date.month, date.day),
      time: time,
      location:
          (data['clinicName'] as String?) ?? (data['location'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'upcoming',
      userId: data['userId'] as String?,
      doctorId: data['doctorId'] as String?,
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore({
    required String userId,
    required String appointmentId,
  }) {
    final DateTime dateOnly = DateTime(date.year, date.month, date.day);
    final DateTime dateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    return {
      'appointmentId': appointmentId,
      'userId': userId,
      'doctorId': doctorId,
      'doctorName': name,
      'doctorSpecialty': specialty,
      'clinicName': location,
      'appointmentDate': Timestamp.fromDate(dateOnly),
      'appointmentTime': _formatTime24(time),
      'appointmentDateTime': Timestamp.fromDate(dateTime),
      'status': status,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class AppointmentsManager extends ChangeNotifier {
  static final AppointmentsManager _instance = AppointmentsManager._internal();
  factory AppointmentsManager() => _instance;
  AppointmentsManager._internal()
      : _db = kIsWeb ? null : FirebaseFirestore.instance,
        _auth = kIsWeb ? null : FirebaseAuth.instance {
    _bindAuth();
  }

  final FirebaseFirestore? _db;
  final FirebaseAuth? _auth;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _appointmentsSubscription;

  List<AppointmentData> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppointmentData> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _bindAuth() {
    if (kIsWeb) {
      _loadWebAppointments(this);
      return;
    }
    _authSubscription = _auth!.authStateChanges().listen((user) {
      _appointmentsSubscription?.cancel();
      if (user == null) {
        _appointments = [];
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();
      _appointmentsSubscription = _db!
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .listen(
        (snapshot) {
          _appointments =
              snapshot.docs.map(AppointmentData.fromFirestore).toList();
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (_) {
          _appointments = [];
          _isLoading = false;
          _errorMessage = 'Unable to load appointments.';
          notifyListeners();
        },
      );
    });
  }

  Future<void> addAppointment(AppointmentData appointment) async {
    if (kIsWeb) {
      await _webAddAppointment(appointment);
      return;
    }
    final user = _auth!.currentUser;
    if (user == null) {
      throw Exception('User not authenticated.');
    }
    final doc = _db!.collection('appointments').doc();
    await doc.set(
      appointment.toFirestore(userId: user.uid, appointmentId: doc.id),
    );
  }

  Future<void> cancelAppointment(String id) async {
    if (kIsWeb) {
      await _webDeleteAppointment(id);
      return;
    }
    await _db!.collection('appointments').doc(id).delete();
  }

  Future<void> updateAppointment(
    String id,
    DateTime newDate,
    TimeOfDay newTime,
  ) async {
    if (kIsWeb) {
      await _webUpdateAppointment(id, newDate, newTime);
      return;
    }
    final DateTime dateOnly =
        DateTime(newDate.year, newDate.month, newDate.day);
    final DateTime dateTime = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      newTime.hour,
      newTime.minute,
    );
    await _db!.collection('appointments').doc(id).update({
      'appointmentDate': Timestamp.fromDate(dateOnly),
      'appointmentTime': _formatTime24(newTime),
      'appointmentDateTime': Timestamp.fromDate(dateTime),
      'status': 'upcoming',
    });
  }
}

TimeOfDay _parseTime(String time) {
  final parts = time.split(':');
  final hour = int.tryParse(parts.first) ?? 9;
  final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  return TimeOfDay(hour: hour, minute: minute);
}

String _formatTime24(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

Future<void> _setWebError(
  AppointmentsManager manager,
  String message,
) async {
  manager._appointments = [];
  manager._isLoading = false;
  manager._errorMessage = message;
  manager.notifyListeners();
}

Future<void> _loadWebAppointments(AppointmentsManager manager) async {
  if (!AuthSession.isSignedIn) {
    await _setWebError(manager, 'Please login to view appointments.');
    return;
  }

  manager._isLoading = true;
  manager._errorMessage = null;
  manager.notifyListeners();

  final projectId = DefaultFirebaseOptions.currentPlatform.projectId;
  final uri = Uri.parse(
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents:runQuery',
  );

  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthSession.idToken}',
    },
    body: jsonEncode({
      'structuredQuery': {
        'from': [
          {'collectionId': 'appointments'}
        ],
        'where': {
          'fieldFilter': {
            'field': {'fieldPath': 'userId'},
            'op': 'EQUAL',
            'value': {'stringValue': AuthSession.userId},
          }
        },
      },
    }),
  );

  if (response.statusCode != 200) {
    await _setWebError(manager, 'Unable to load appointments.');
    return;
  }

  final List<dynamic> results = jsonDecode(response.body) as List<dynamic>;
  final List<AppointmentData> items = [];
  for (final result in results) {
    final doc = (result as Map<String, dynamic>)['document']
        as Map<String, dynamic>?;
    if (doc == null) continue;
    final parsed = _fromRestDocument(doc);
    if (parsed != null) items.add(parsed);
  }

  manager._appointments = items;
  manager._isLoading = false;
  manager._errorMessage = null;
  manager.notifyListeners();
}

AppointmentData? _fromRestDocument(Map<String, dynamic> doc) {
  final name = doc['name']?.toString() ?? '';
  final id = name.split('/').isNotEmpty ? name.split('/').last : name;
  final fields = doc['fields'] as Map<String, dynamic>? ?? {};

  final doctorName = _stringField(fields['doctorName']);
  final specialty = _stringField(fields['doctorSpecialty']);
  final location = _stringField(fields['clinicName']);
  final dateTimeValue = _timestampField(fields['appointmentDateTime']);
  final dateValue = _timestampField(fields['appointmentDate']);
  final timeRaw = _stringField(fields['appointmentTime']);

  final date = dateTimeValue ?? dateValue ?? DateTime.now();
  final time = timeRaw != null && timeRaw.isNotEmpty
      ? _parseTime(timeRaw)
      : TimeOfDay.fromDateTime(date);

  return AppointmentData(
    id: id,
    name: doctorName ?? '',
    specialty: specialty ?? '',
    date: DateTime(date.year, date.month, date.day),
    time: time,
    location: location ?? '',
  );
}

String? _stringField(dynamic field) {
  if (field is Map<String, dynamic>) {
    return field['stringValue']?.toString();
  }
  return null;
}

DateTime? _timestampField(dynamic field) {
  if (field is Map<String, dynamic>) {
    final value = field['timestampValue']?.toString();
    if (value != null) return DateTime.tryParse(value);
  }
  return null;
}

Future<void> _webAddAppointment(AppointmentData appointment) async {
  if (!AuthSession.isSignedIn) {
    throw Exception('User not authenticated.');
  }
  final manager = AppointmentsManager();
  final projectId = DefaultFirebaseOptions.currentPlatform.projectId;
  final docId = DateTime.now().millisecondsSinceEpoch.toString();
  final uri = Uri.parse(
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/appointments?documentId=$docId',
  );

  final dateOnly = DateTime(
    appointment.date.year,
    appointment.date.month,
    appointment.date.day,
  ).toUtc();
  final dateTime = DateTime(
    appointment.date.year,
    appointment.date.month,
    appointment.date.day,
    appointment.time.hour,
    appointment.time.minute,
  ).toUtc();

  final body = {
    'fields': {
      'appointmentId': {'stringValue': docId},
      'userId': {'stringValue': AuthSession.userId},
      'doctorName': {'stringValue': appointment.name},
      'doctorSpecialty': {'stringValue': appointment.specialty},
      'clinicName': {'stringValue': appointment.location},
      'appointmentDate': {'timestampValue': dateOnly.toIso8601String()},
      'appointmentTime': {'stringValue': _formatTime24(appointment.time)},
      'appointmentDateTime': {'timestampValue': dateTime.toIso8601String()},
      'status': {'stringValue': appointment.status},
    },
  };

  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthSession.idToken}',
    },
    body: jsonEncode(body),
  );

  if (response.statusCode != 200) {
    throw Exception('Unable to create appointment.');
  }

  await _loadWebAppointments(manager);
}

Future<void> _webDeleteAppointment(String id) async {
  if (!AuthSession.isSignedIn) {
    throw Exception('User not authenticated.');
  }
  final manager = AppointmentsManager();
  final projectId = DefaultFirebaseOptions.currentPlatform.projectId;
  final uri = Uri.parse(
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/appointments/$id',
  );

  final response = await http.delete(
    uri,
    headers: {
      'Authorization': 'Bearer ${AuthSession.idToken}',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Unable to delete appointment.');
  }

  await _loadWebAppointments(manager);
}

Future<void> _webUpdateAppointment(
  String id,
  DateTime newDate,
  TimeOfDay newTime,
) async {
  if (!AuthSession.isSignedIn) {
    throw Exception('User not authenticated.');
  }
  final manager = AppointmentsManager();
  final projectId = DefaultFirebaseOptions.currentPlatform.projectId;
  final uri = Uri.parse(
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/appointments/$id?updateMask.fieldPaths=appointmentDate&updateMask.fieldPaths=appointmentTime&updateMask.fieldPaths=appointmentDateTime',
  );

  final dateOnly = DateTime(newDate.year, newDate.month, newDate.day).toUtc();
  final dateTime = DateTime(
    newDate.year,
    newDate.month,
    newDate.day,
    newTime.hour,
    newTime.minute,
  ).toUtc();

  final body = {
    'fields': {
      'appointmentDate': {'timestampValue': dateOnly.toIso8601String()},
      'appointmentTime': {'stringValue': _formatTime24(newTime)},
      'appointmentDateTime': {'timestampValue': dateTime.toIso8601String()},
    },
  };

  final response = await http.patch(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthSession.idToken}',
    },
    body: jsonEncode(body),
  );

  if (response.statusCode != 200) {
    throw Exception('Unable to update appointment.');
  }

  await _loadWebAppointments(manager);
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
