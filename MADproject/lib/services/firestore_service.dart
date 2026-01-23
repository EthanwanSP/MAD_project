import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> ensureUserDoc({
    required String uid,
    required String email,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      await docRef.set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.update({
        'email': email,
      });
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAppointments(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .orderBy('datetime')
        .snapshots();
  }

  Future<void> addAppointment({
    required String uid,
    required String title,
    required DateTime dateTime,
    required String status,
  }) {
    return _firestore.collection('users').doc(uid).collection('appointments').add({
      'title': title,
      'datetime': Timestamp.fromDate(dateTime),
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAppointment({
    required String uid,
    required String appointmentId,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .doc(appointmentId)
        .delete();
  }

  Future<void> updateAppointmentStatus({
    required String uid,
    required String appointmentId,
    required String status,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': status});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMedicines(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('medicines')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addMedicine({
    required String uid,
    required String name,
    required String dosage,
    required String frequency,
  }) {
    return _firestore.collection('users').doc(uid).collection('medicines').add({
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMedicine({
    required String uid,
    required String medicineId,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('medicines')
        .doc(medicineId)
        .delete();
  }
}
