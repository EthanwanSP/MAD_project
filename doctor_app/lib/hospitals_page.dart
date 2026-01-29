import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_theme.dart';
import 'home_shell.dart';
import 'google_map.dart';

class HospitalsPage extends StatefulWidget {
  const HospitalsPage({super.key});

  @override
  State<HospitalsPage> createState() => _HospitalsPageState();
}

class _HospitalsPageState extends State<HospitalsPage> {
  final List<HospitalData> hospitals = [
    HospitalData(
      name: 'Raffles Medical Clinic',
      distance: '2.5 km',
      eta: '10 min drive',
      address: '585 North Bridge Road, Raffles Hospital, Singapore 188770',
      latitude: 1.3006,
      longitude: 103.8634,
    ),
    HospitalData(
      name: 'Jurong Medical Centre',
      distance: '12.8 km',
      eta: '25 min drive',
      address: '1 Jurong East Street 21, Singapore 609606',
      latitude: 1.3336,
      longitude: 103.7436,
    ),
    HospitalData(
      name: 'Changi General Hospital',
      distance: '8.3 km',
      eta: '18 min drive',
      address: '2 Simei Street 3, Singapore 529889',
      latitude: 1.3404,
      longitude: 103.9496,
    ),
    HospitalData(
      name: 'Khoo Teck Puat Hospital',
      distance: '15.2 km',
      eta: '28 min drive',
      address: '90 Yishun Central, Singapore 768828',
      latitude: 1.4241,
      longitude: 103.8376,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: kPaper,
        child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(top: 480), // Space for fixed header + map
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Nearby',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 10),
              ...hospitals.map((hospital) => _HospitalCard(
                    hospital: hospital,
                    onTap: () => _openGoogleMaps(hospital),
                  )),
              const SizedBox(height: 24),
            ],
          ),
          // Fixed header and map at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 22),
                  decoration: const BoxDecoration(
                    color: kBlush,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const HomeShell(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_back, color: kInk),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nearest Hospitals',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Find care near your location',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: SizedBox(
                        height: 330,
                        width: double.infinity,
                        child: MyGooglemap(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    )
    );
  }

  Future<void> _openGoogleMaps(HospitalData hospital) async {
    // Create Google Maps URL with coordinates
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${hospital.latitude},${hospital.longitude}',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open maps for ${hospital.name}'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error opening maps'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}

class HospitalData {
  final String name;
  final String distance;
  final String eta;
  final String address;
  final double latitude;
  final double longitude;

  HospitalData({
    required this.name,
    required this.distance,
    required this.eta,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class _HospitalCard extends StatelessWidget {
  const _HospitalCard({
    required this.hospital,
    required this.onTap,
  });

  final HospitalData hospital;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kPaper,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kInk.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: kInk.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: kPeach.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_hospital,
                color: kInk,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hospital.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${hospital.distance} • ${hospital.eta}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }
}