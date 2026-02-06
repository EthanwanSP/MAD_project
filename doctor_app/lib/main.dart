
import 'package:doctor_app/calling_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'appointments_page.dart';
import 'calendar_page.dart';
import 'hospitals_page.dart';
import 'login_page.dart';
import 'queue_page.dart';
import 'tele_consult_page.dart';
import 'forgot_password_page.dart';
import 'signup_page.dart';
import 'home_shell.dart';
import 'providers/cart_provider.dart';
import 'screens/pharmacy_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/address_screen.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Doctor + Connect',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const _AuthGate(),
        routes: {
          '/appointments': (_) => const AppointmentsPage(),
          '/shop': (_) => const PharmacyScreen(),
          '/queue': (_) => const QueuePage(),
          '/calendar': (_) => const CalendarPage(),
          '/teleconsult': (_) => const TeleConsultPage(),
          '/hospitals': (_) => const HospitalsPage(),
          '/login': (_) => const LoginPage(),
          '/signUp': (_) => const SignupPage(),
          '/forgotPassword': (_) => const ForgotPassword(),
          '/calling': (_) => const CallingPage(),
          '/cart': (_) => const CartScreen(),
          '/address': (_) => const AddressScreen(),
        },
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _checkedRedirect = false;

  @override
  void initState() {
    super.initState();
    _handleRedirect();
  }

  Future<void> _handleRedirect() async {
    if (_checkedRedirect) return;
    _checkedRedirect = true;
    if (kIsWeb) {
      try {
        await FirebaseAuth.instance.getRedirectResult();
      } catch (_) {}
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data != null) {
          return HomeShell();
        }
        return const LoginPage();
      },
    );
  }
}
