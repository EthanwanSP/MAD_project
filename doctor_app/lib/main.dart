
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/calling_page.dart';
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'appointments_page.dart';
import 'calendar_page.dart';
import 'hospitals_page.dart';
import 'login_page.dart';
import 'queue_page.dart';
import 'shop_page.dart';
import 'tele_consult_page.dart';
import 'forgot_password_page.dart';
import 'signup_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor + Connect',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const LoginPage(),
      routes: {
        '/appointments': (_) => const AppointmentsPage(),
        '/shop': (_) => const ShopPage(),
        '/queue': (_) => const QueuePage(),
        '/calendar': (_) => const CalendarPage(),
        '/teleconsult': (_) => const TeleConsultPage(),
        '/hospitals': (_) => const HospitalsPage(),
        '/login': (_) => const LoginPage(),
        '/signUp': (_) => const SignupPage(),
        '/forgotPassword': (_) => const ForgotPassword(),
        '/calling': (_) => const CallingPage(),
      },
    );
  }
}
