import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'app_theme.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.centerRight,
          colors: [kPaper,kPeach,kBlush],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                Lottie.network('https://lottie.host/4c68f94b-88dd-40cb-a7b8-f1f4d952e1ca/gsZRXU1w06.json',
                width: 90,
                height: 90),
                
              
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome in, Amelia!', style: Theme.of(context).textTheme.titleLarge),
                    Text('Your health, streamlined', style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {Navigator.pushNamed(context, '/profilePage');},
                  iconSize: 40,
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                  icon: const Icon(Icons.person),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              
              children: [
              FilledButton(onPressed: 
              (){}, 
              style: FilledButton.styleFrom(backgroundColor: kInk, foregroundColor: Colors.white,
              minimumSize: Size(230, 55)),
              child: Text('Book now', style: TextStyle())),
              SizedBox(width: 10,),
              FilledButton(onPressed: 
              (){}, 
              style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: kInk,
              minimumSize: Size(230, 55)),
              child: Text('Schedule later', style: TextStyle())),
              
              
            ],),
            
            const SizedBox(height: 18),
            Text('Quick services', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ActionTile(
                    icon: Icons.assignment_outlined,
                    label: 'Appointments',
                    iconColor: Colors.blue,
                    onTap: () => Navigator.of(context).pushNamed('/appointments'),
                  ),
                  const SizedBox(width: 10),
                  ActionTile(
                    icon: Icons.storefront_outlined,
                    label: 'Home remedies',
                    iconColor: Colors.green,
                    onTap: () => Navigator.of(context).pushNamed('/shop'),
                  ),
                  const SizedBox(width: 10),
                  ActionTile(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Queue no.',
                    iconColor: Colors.orange,
                    onTap: () => Navigator.of(context).pushNamed('/queue'),
                  ),
                  const SizedBox(width: 10),
                  ActionTile(
                    icon: Icons.calendar_month_outlined,
                    label: 'Calendar',
                    iconColor: Colors.purple,
                    onTap: () => Navigator.of(context).pushNamed('/calendar'),
                  ),
                  const SizedBox(width: 10),
                  ActionTile(
                    icon: Icons.video_camera_front_outlined,
                    label: ' Online consult',
                    iconColor: Colors.red,
                    onTap: () => Navigator.of(context).pushNamed('/teleconsult'),
                  ),
                  const SizedBox(width: 10),
                  ActionTile(
                    icon: Icons.map_outlined,
                    label: 'Hospitals nearby',
                    iconColor: Colors.teal,
                    onTap: () => Navigator.of(context).pushNamed('/hospitals'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('Promotions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  PromotionTile(
                    title: 'Special Offer!',
                    description: 'Get 20% off on your first consultation',
                    backgroundColor: Colors.deepPurple,
                  ),
                  const SizedBox(width: 10),
                  PromotionTile(
                    title: 'Health Checkup',
                    description: 'Complete body checkup at discounted rates',
                    backgroundColor: Colors.teal,
                  ),
                  const SizedBox(width: 10),
                  PromotionTile(
                    title: 'Free Delivery',
                    description: 'Free home delivery on medicines above \$50',
                    backgroundColor: Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('Today appointments', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Appointments updates will appear here.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class ActionTile extends StatefulWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  State<ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<ActionTile> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Material(
        color: kPaper,       
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.label} opened')),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 28),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PromotionTile extends StatelessWidget {
  const PromotionTile({
    super.key,
    required this.title,
    required this.description,
    required this.backgroundColor,
  });

  final String title;
  final String description;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer, color: Colors.white, size: 36),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}