import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: NavigationBar(
          height: 70,
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: const [
            NavigationDestination(
              icon: _NavIcon(icon: Icons.home_outlined),
              selectedIcon: _NavIcon(icon: Icons.home_outlined, isSelected: true),
              label: 'Home',
            ),
            NavigationDestination(
              icon: _NavIcon(icon: Icons.event_available_outlined),
              selectedIcon: _NavIcon(icon: Icons.event_available_outlined, isSelected: true),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: _NavIcon(icon: Icons.storefront_outlined),
              selectedIcon: _NavIcon(icon: Icons.storefront_outlined, isSelected: true),
              label: 'Shop',
            ),
            NavigationDestination(
              icon: _NavIcon(icon: Icons.person_outline),
              selectedIcon: _NavIcon(icon: Icons.person_outline, isSelected: true),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    this.isSelected = false,
  });

  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: isSelected ? Colors.white.withOpacity(0.18) : Colors.transparent,
      ),
      child: Icon(icon),
    );
  }
}
