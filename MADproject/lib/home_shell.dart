import 'package:flutter/material.dart';

import 'appointments_page.dart';
import 'home_dashboard.dart';
import 'profile_page.dart';
import 'shop_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeDashboard(),
      const AppointmentsPage(),
      const ShopPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() => _selectedIndex = value);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.event_available_outlined), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
