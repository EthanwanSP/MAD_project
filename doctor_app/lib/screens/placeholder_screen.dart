import 'package:flutter/material.dart';

import '../app_theme.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBlush,
        elevation: 0,
        title: Text(title),
      ),
      body: Center(
        child: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
