import 'package:doctor_app/login_page.dart';

import 'app_theme.dart';
import 'package:flutter/material.dart';
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
      home: LoginPage()
    );
  }
}
