import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app_theme.dart';
import 'auth_session.dart';
import 'customize_profile_page.dart';
import 'firebase_options.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_radii.dart';
import 'app_text_styles.dart';
import 'screens/placeholder_screen.dart';
import 'screens/help_center_screen.dart';
import 'screens/report_issue_screen.dart';
import 'screens/about_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/my_orders_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _recordController = TextEditingController();
  Map<String, dynamic>? _webHealthProfile;
  bool _webHasAddress = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _loadWebHealthProfile();
    }
  }

  @override
  void dispose() {
    _recordController.dispose();
    super.dispose();
  }

  Future<void> _saveHealthProfile({
    required String bloodType,
    required String allergies,
    required String conditions,
    required String emergencyName,
    required String emergencyPhone,
    required String notes,
  }) async {
    final allergyList = allergies
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final conditionList = conditions
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (kIsWeb) {
      if (!AuthSession.isSignedIn) {
        _showSnack('Please sign in to save health profile');
        return;
      }
      try {
        final projectId = DefaultFirebaseOptions.currentPlatform.projectId;
        final uri = Uri.parse(
          'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users/${AuthSession.userId}?updateMask.fieldPaths=healthProfile',
        );
        final body = {
          'fields': {
            'healthProfile': {
              'mapValue': {
                'fields': {
                  'bloodType': {'stringValue': bloodType},
                  'allergies': {
                    'arrayValue': {
                      'values': allergyList
                          .map((e) => {'stringValue': e})
                          .toList(),
                    }
                  },
                  'conditions': {
                    'arrayValue': {
                      'values': conditionList
                          .map((e) => {'stringValue': e})
                          .toList(),
                    }
                  },
                  'emergencyName': {'stringValue': emergencyName},
                  'emergencyPhone': {'stringValue': emergencyPhone},
                  'notes': {'stringValue': notes},
                  'updatedAt': {
                    'timestampValue':
                        DateTime.now().toUtc().toIso8601String()
                  },
                },
              },
            },
          },
        };
        final response = await http.patch(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthSession.idToken}',
          },
          body: jsonEncode(body),
        );
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }
        await _loadWebHealthProfile();
        _showSnack('Health profile updated');
      } catch (e) {
        _showSnack('Unable to save health profile: $e', isError: true);
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack('Please sign in to save health profile');
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'healthProfile': {
          'bloodType': bloodType,
          'allergies': allergyList,
          'conditions': conditionList,
          'emergencyName': emergencyName,
          'emergencyPhone': emergencyPhone,
          'notes': notes,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
      _showSnack('Health profile updated');
    } catch (e) {
      _showSnack('Unable to save health profile: $e', isError: true);
    }
  }

  Future<void> _loadWebHealthProfile() async {
    if (!AuthSession.isSignedIn) {
      setState(() {
        _webHealthProfile = null;
      });
      return;
    }
    try {
      final projectId = DefaultFirebaseOptions.currentPlatform.projectId;
      final uri = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users/${AuthSession.userId}',
      );
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${AuthSession.idToken}',
        },
      );
      if (response.statusCode != 200) {
        setState(() {
          _webHealthProfile = null;
        });
        return;
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final fields = decoded['fields'] as Map<String, dynamic>? ?? {};
      final healthProfile = fields['healthProfile']?['mapValue']?['fields']
              as Map<String, dynamic>? ??
          {};
      final defaultAddress = fields['defaultAddress']?['mapValue']?['fields']
              as Map<String, dynamic>? ??
          {};
      final line1 = defaultAddress['line1']?['stringValue']?.toString() ?? '';
      setState(() {
        _webHealthProfile = {
          'bloodType':
              healthProfile['bloodType']?['stringValue']?.toString() ?? '',
          'emergencyName': healthProfile['emergencyName']?['stringValue']
                  ?.toString() ??
              '',
          'emergencyPhone': healthProfile['emergencyPhone']?['stringValue']
                  ?.toString() ??
              '',
          'notes': healthProfile['notes']?['stringValue']?.toString() ?? '',
          'allergies': _parseArray(healthProfile['allergies']),
          'conditions': _parseArray(healthProfile['conditions']),
        };
        _webHasAddress = line1.trim().isNotEmpty;
      });
    } catch (_) {
      setState(() {
        _webHealthProfile = null;
      });
    }
  }

  List<String> _parseArray(dynamic field) {
    dynamic values;
    if (field is Map<String, dynamic>) {
      values = field['arrayValue']?['values'];
    }
    if (values is List) {
      return values
          .map((e) => e['stringValue']?.toString())
          .whereType<String>()
          .toList();
    }
    return [];
  }

  String _formatMemberSince(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Member since -';
    }
    final date = timestamp.toDate();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return 'Member since ${months[date.month - 1]} ${date.year}';
  }

  bool _hasHealthData(Map<String, dynamic>? profile) {
    final data = profile ?? {};
    final bloodType = ((data['bloodType'] as String?) ?? '').trim();
    final emergencyName = ((data['emergencyName'] as String?) ?? '').trim();
    final emergencyPhone = ((data['emergencyPhone'] as String?) ?? '').trim();
    final notes = ((data['notes'] as String?) ?? '').trim();
    final allergies = (data['allergies'] as List?)?.whereType<String>().toList() ?? [];
    final conditions = (data['conditions'] as List?)?.whereType<String>().toList() ?? [];
    return bloodType.isNotEmpty ||
        emergencyName.isNotEmpty ||
        emergencyPhone.isNotEmpty ||
        notes.isNotEmpty ||
        allergies.isNotEmpty ||
        conditions.isNotEmpty;
  }

  void _showProfileChecklist({
    required bool personalInfoDone,
    required bool addressDone,
    required bool healthInfoDone,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) {
        Widget row(String label, bool done) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(
                  done ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 20,
                  color: done ? Colors.green : AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label, style: AppTextStyles.cardTitle(context)),
                ),
                Text(
                  done ? 'Done' : 'Missing',
                  style: AppTextStyles.secondary(context),
                ),
              ],
            ),
          );
        }

        return AlertDialog(
          title: const Text('Complete profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              row('Personal info', personalInfoDone),
              row('Address', addressDone),
              row('Health info', healthInfoDone),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _openPlaceholder(String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaceholderScreen(
          title: title,
          subtitle: 'Coming soon',
        ),
      ),
    );
  }

  Future<void> _openHealthProfileSheet() async {
    _recordController.clear();
    final bloodTypeController = TextEditingController();
    final allergiesController = TextEditingController();
    final conditionsController = TextEditingController();
    final emergencyNameController = TextEditingController();
    final emergencyPhoneController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Update health profile',
                        style: AppTextStyles.sectionTitle(context)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: bloodTypeController,
                decoration: const InputDecoration(hintText: 'Blood type (e.g. O+)'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: allergiesController,
                decoration: const InputDecoration(hintText: 'Allergies (comma separated)'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: conditionsController,
                decoration:
                    const InputDecoration(hintText: 'Conditions (comma separated)'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: emergencyNameController,
                decoration:
                    const InputDecoration(hintText: 'Emergency contact name'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: emergencyPhoneController,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(hintText: 'Emergency contact phone'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _recordController,
                decoration: const InputDecoration(
                  hintText: 'Additional notes (optional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kInk,
                    foregroundColor: kPaper,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _saveHealthProfile(
                      bloodType: bloodTypeController.text.trim(),
                      allergies: allergiesController.text.trim(),
                      conditions: conditionsController.text.trim(),
                      emergencyName: emergencyNameController.text.trim(),
                      emergencyPhone: emergencyPhoneController.text.trim(),
                      notes: _recordController.text.trim(),
                    );
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
    bloodTypeController.dispose();
    allergiesController.dispose();
    conditionsController.dispose();
    emergencyNameController.dispose();
    emergencyPhoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = kIsWeb ? null : FirebaseAuth.instance.currentUser;
    final displayName =
        kIsWeb ? (AuthSession.displayName ?? 'User') : (user?.displayName ?? '');
    final email = kIsWeb ? (AuthSession.email ?? '') : (user?.email ?? '');
    final verified = user?.emailVerified ?? false;

    final userStream = kIsWeb || user == null
        ? null
        : FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots();

    final healthProfileStream = kIsWeb || user == null
        ? null
        : FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots();
    final addressesStream = kIsWeb || user == null
        ? null
        : FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .snapshots();

    return Scaffold(
      backgroundColor: AppColors.primarySoft,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          children: [
            _ProfileHeader(
              displayName: displayName,
              email: email,
              verified: verified,
              onEdit: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CustomizeProfilePage(
                      displayName: displayName,
                      email: email,
                    ),
                  ),
                );
              },
              userStream: userStream,
              memberSinceFormatter: _formatMemberSince,
            ),
            const SizedBox(height: AppSpacing.lg),
            _QuickActionsRow(
              actions: [
                _QuickAction(
                  icon: Icons.event_available_outlined,
                  label: 'My Bookings',
                  onTap: () => Navigator.of(context).pushNamed('/appointments'),
                ),
                _QuickAction(
                  icon: Icons.shopping_bag_outlined,
                  label: 'My Orders',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                  ),
                ),
                _QuickAction(
                  icon: Icons.confirmation_number_outlined,
                  label: 'My Queue',
                  onTap: () => Navigator.of(context).pushNamed('/queue'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _ProfileSectionCard(
              title: 'Health profile',
              subtitle: 'Summary of your health details',
              trailing: const SizedBox.shrink(),
              child: kIsWeb
                  ? _HealthSummary(
                      profile: _webHealthProfile,
                      onAdd: _openHealthProfileSheet,
                    )
                  : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: healthProfileStream,
                      builder: (context, snapshot) {
                        final data = snapshot.data?.data() ?? {};
                        return _HealthSummary(
                          profile: data['healthProfile'] as Map<String, dynamic>?,
                          onAdd: _openHealthProfileSheet,
                        );
                      },
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (kIsWeb)
              Builder(
                builder: (context) {
                  final hasName = (AuthSession.displayName ?? '').trim().isNotEmpty;
                  final hasEmail = (AuthSession.email ?? '').trim().isNotEmpty;
                  final personalInfoDone = hasName && hasEmail;
                  final healthInfoDone = _hasHealthData(_webHealthProfile);
                  final addressDone = _webHasAddress;
                  final doneCount = [
                    personalInfoDone,
                    addressDone,
                    healthInfoDone,
                  ].where((done) => done).length;
                  final completion = doneCount / 3.0;
                  return _ProfileCompletenessCard(
                    completion: completion,
                    onTap: () => _showProfileChecklist(
                      personalInfoDone: personalInfoDone,
                      addressDone: addressDone,
                      healthInfoDone: healthInfoDone,
                    ),
                  );
                },
              )
            else
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: userStream,
                builder: (context, userSnapshot) {
                  final userData = userSnapshot.data?.data() ?? {};
                  final userName = ((userData['name'] as String?) ?? '').trim();
                  final userEmail = ((userData['email'] as String?) ?? email).trim();
                  final rawHealth = userData['healthProfile'];
                  final healthProfile = rawHealth is Map<String, dynamic>
                      ? rawHealth
                      : <String, dynamic>{};
                  final healthInfoDone = _hasHealthData(healthProfile);
                  final rawDefaultAddress = userData['defaultAddress'];
                  final defaultLine1 = rawDefaultAddress is Map
                      ? '${rawDefaultAddress['line1'] ?? ''}'.trim()
                      : '';
                  final hasDefaultAddress = defaultLine1.isNotEmpty;
                  final personalInfoDone =
                      userName.isNotEmpty && userEmail.isNotEmpty;

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: addressesStream,
                    builder: (context, addressSnapshot) {
                      final addressDone = hasDefaultAddress ||
                          ((addressSnapshot.data?.docs.length ?? 0) > 0);
                      final doneCount = [
                        personalInfoDone,
                        addressDone,
                        healthInfoDone,
                      ].where((done) => done).length;
                      final completion = doneCount / 3.0;
                      return _ProfileCompletenessCard(
                        completion: completion,
                        onTap: () => _showProfileChecklist(
                          personalInfoDone: personalInfoDone,
                          addressDone: addressDone,
                          healthInfoDone: healthInfoDone,
                        ),
                      );
                    },
                  );
                },
              ),
            const SizedBox(height: AppSpacing.lg),
            _SettingsGroupCard(
              title: 'Account',
              tiles: [
                SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Personal info',
                  subtitle: 'Profile and contact details',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CustomizeProfilePage(
                          displayName: displayName,
                          email: email,
                        ),
                      ),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.location_on_outlined,
                  title: 'Address book',
                  subtitle: 'Manage saved addresses',
                  onTap: () => Navigator.of(context).pushNamed(
                    '/address',
                    arguments: {'fromCart': false},
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SettingsGroupCard(
              title: 'Support',
              tiles: [
                SettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help center',
                  subtitle: 'FAQ and support',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                  ),
                ),
                SettingsTile(
                  icon: Icons.bug_report_outlined,
                  title: 'Report issue',
                  subtitle: 'Let us know if something is wrong',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
                  ),
                ),
                SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App information',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SettingsGroupCard(
              title: 'Legal',
              tiles: [
                SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy policy',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  ),
                ),
                SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of service',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TermsScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: kInk,
                  foregroundColor: kPaper,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                  } catch (_) {}
                  AuthSession.clear();
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true)
                        .pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  }
                },
                child: const Text('Log out'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                'Version 1.0.0',
                style: AppTextStyles.secondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.verified,
    required this.onEdit,
    required this.userStream,
    required this.memberSinceFormatter,
  });

  final String displayName;
  final String email;
  final bool verified;
  final VoidCallback onEdit;
  final Stream<DocumentSnapshot<Map<String, dynamic>>>? userStream;
  final String Function(Timestamp? timestamp) memberSinceFormatter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: const Icon(Icons.person, color: AppColors.textPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: kIsWeb || userStream == null
                ? _ProfileHeaderText(
                    name: displayName,
                    email: email,
                    memberSince: '',
                    verified: verified,
                  )
                : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: userStream,
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data() ?? {};
                      final name = (data['name'] as String?)?.isNotEmpty == true
                          ? (data['name'] as String)
                          : displayName;
                      final emailValue =
                          (data['email'] as String?) ?? email;
                      return _ProfileHeaderText(
                        name: name,
                        email: emailValue,
                        memberSince: '',
                        verified: verified,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderText extends StatelessWidget {
  const _ProfileHeaderText({
    required this.name,
    required this.email,
    required this.memberSince,
    required this.verified,
  });

  final String name;
  final String email;
  final String memberSince;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                name.isEmpty ? 'User' : name,
                style: AppTextStyles.headline(context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (verified)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Verified',
                    style: AppTextStyles.secondary(context)),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(email, style: AppTextStyles.secondary(context)),
        const SizedBox(height: 4),
        const SizedBox.shrink(),
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.actions});

  final List<_QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: actions
          .map(
            (action) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: action,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.element),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.element),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(label, style: AppTextStyles.cardTitle(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.sectionTitle(context)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.secondary(context)),
                  ],
                ),
              ),
              trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _HealthSummary extends StatelessWidget {
  const _HealthSummary({required this.profile, required this.onAdd});

  final Map<String, dynamic>? profile;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final data = profile ?? {};
    final bloodType = (data['bloodType'] as String?) ?? '';
    final allergies = (data['allergies'] as List?)?.cast<String>() ?? [];
    final conditions = (data['conditions'] as List?)?.cast<String>() ?? [];
    final emergencyName = (data['emergencyName'] as String?) ?? '';
    final emergencyPhone = (data['emergencyPhone'] as String?) ?? '';

    final hasData = bloodType.isNotEmpty ||
        allergies.isNotEmpty ||
        conditions.isNotEmpty ||
        emergencyName.isNotEmpty ||
        emergencyPhone.isNotEmpty;

    if (!hasData) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No health data yet', style: AppTextStyles.cardTitle(context)),
          const SizedBox(height: 4),
          Text('Add allergies or conditions to stay prepared.',
              style: AppTextStyles.secondary(context)),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: onAdd,
            child: const Text('Edit health info'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StatChip(label: 'Allergies', value: '${allergies.length}'),
            const SizedBox(width: 12),
            _StatChip(label: 'Conditions', value: '${conditions.length}'),
          ],
        ),
        const SizedBox(height: 12),
        if (bloodType.isNotEmpty)
          Text('Blood type: $bloodType', style: AppTextStyles.secondary(context)),
        if (emergencyName.isNotEmpty || emergencyPhone.isNotEmpty)
          Text(
            'Emergency: $emergencyName $emergencyPhone',
            style: AppTextStyles.secondary(context),
          ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onAdd,
          child: const Text('Edit health info'),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.sectionTitle(context)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.secondary(context)),
          ],
        ),
      ),
    );
  }
}

class _ProfileCompletenessCard extends StatelessWidget {
  const _ProfileCompletenessCard({
    required this.completion,
    required this.onTap,
  });

  final double completion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile completeness',
              style: AppTextStyles.sectionTitle(context)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completion,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            color: AppColors.primary,
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text('${(completion * 100).round()}% complete',
              style: AppTextStyles.secondary(context)),
          const SizedBox(height: 8),
          TextButton(onPressed: onTap, child: const Text('Complete profile')),
        ],
      ),
    );
  }
}

class _SettingsGroupCard extends StatelessWidget {
  const _SettingsGroupCard({required this.title, required this.tiles});

  final String title;
  final List<SettingsTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionTitle(context)),
          const SizedBox(height: AppSpacing.sm),
          ..._buildTiles(),
        ],
      ),
    );
  }

  List<Widget> _buildTiles() {
    final items = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      items.add(tiles[i]);
      if (i != tiles.length - 1) {
        items.add(Divider(height: 1, color: AppColors.textSecondary.withOpacity(0.2)));
      }
    }
    return items;
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      onTap: onTap,
      leading: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppRadii.element),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
      title: Text(title, style: AppTextStyles.cardTitle(context)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: AppTextStyles.secondary(context)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      minLeadingWidth: 0,
      horizontalTitleGap: 12,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
    );
  }
}
