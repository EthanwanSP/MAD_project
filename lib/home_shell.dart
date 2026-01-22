import 'package:flutter/material.dart';

import 'appointments_page.dart';
import 'home_dashboard.dart';
import 'app_bottom_nav.dart';
import 'profile_page.dart';
import 'shop_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeDashboard(),
      const AppointmentsPage(showBottomNav: false),
      const ShopPage(showBottomNav: false),
      const ProfilePage(showBottomNav: false),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() => _selectedIndex = value);
        },
      ),
    );
  }
}
