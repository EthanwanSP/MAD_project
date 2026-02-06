import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:flutter/material.dart';

import '../appointments_manager.dart';

class BookingResult {
  final String appointmentId;
  final int queueNumber;

  const BookingResult({
    required this.appointmentId,
    required this.queueNumber,
  });
}

class BookingService {
  BookingService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<BookingResult> createBookingAndAssignQueue({
    required AppointmentData appointment,
    required String clinicId,
    required String serviceId,
    required DateTime bookingDate,
    required TimeOfDay time,
    String? slotId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated.');
    }

    final dateOnly = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
    final slot = slotId ?? _formatTime24(time);
    final appointmentRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('appointments')
        .doc();

    final result = await _firestore.runTransaction<BookingResult>((txn) async {
      final nextNumber = Random().nextInt(99) + 1;

      txn.set(appointmentRef, {
        ...appointment.toFirestore(
          userId: user.uid,
          appointmentId: appointmentRef.id,
          queueNumber: nextNumber,
          clinicId: clinicId,
          serviceId: serviceId,
          slotId: slot,
        ),
        'status': 'confirmed',
      });

      return BookingResult(
        appointmentId: appointmentRef.id,
        queueNumber: nextNumber,
      );
    });

    return result;
  }
}

String _buildQueueKey({
  required String clinicId,
  required String serviceId,
  required DateTime date,
  String? slotId,
}) {
  final dateKey = '${date.year.toString().padLeft(4, '0')}'
      '-${date.month.toString().padLeft(2, '0')}'
      '-${date.day.toString().padLeft(2, '0')}';
  final parts = [clinicId, serviceId, dateKey];
  if (slotId != null && slotId.isNotEmpty) {
    parts.add(slotId);
  }
  return parts
      .map((part) => part.replaceAll(RegExp(r'\s+'), '_'))
      .join('__');
}

String _formatTime24(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
