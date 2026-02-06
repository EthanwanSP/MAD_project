import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'app_theme.dart';
import 'auth_session.dart';
import 'firebase_options.dart';

class CustomizeProfilePage extends StatefulWidget {
  const CustomizeProfilePage({
    super.key,
    required this.displayName,
    required this.email,
  });

  final String displayName;
  final String email;

  @override
  State<CustomizeProfilePage> createState() => _CustomizeProfilePageState();
}

class _CustomizeProfilePageState extends State<CustomizeProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();
  bool _isSaving = false;
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.displayName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    Uint8List? bytes;
    if (kIsWeb) {
      bytes = await picked.readAsBytes();
    }
    setState(() {
      _pickedImage = picked;
      _pickedImageBytes = bytes;
    });
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });

    final name = _nameController.text.trim();
    final email = widget.email;
    final phone = _phoneController.text.trim();
    final photoUrl = _photoController.text.trim();

    try {
      if (kIsWeb) {
        if (!AuthSession.isSignedIn) {
          throw Exception('Not signed in.');
        }
        final currentName = AuthSession.displayName;
        final desiredName = name.isNotEmpty ? name : currentName;
        final shouldUpdateName =
            name.isNotEmpty && name != currentName;
        final shouldUpdateEmail = false;

        if (AuthSession.idToken != null &&
            (shouldUpdateName || shouldUpdateEmail)) {
          final apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;
          final updateAuthUri = Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:update?key=$apiKey',
          );
          final updateResponse = await http.post(
            updateAuthUri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'idToken': AuthSession.idToken,
              if (shouldUpdateName) 'displayName': desiredName,
              'returnSecureToken': true,
            }),
          );
          if (updateResponse.statusCode != 200) {
            final errorBody =
                jsonDecode(updateResponse.body) as Map<String, dynamic>?;
            final message =
                errorBody?['error']?['message']?.toString() ??
                    'Unable to update auth profile.';
            throw Exception(message);
          }
          final updateBody =
              jsonDecode(updateResponse.body) as Map<String, dynamic>;
          AuthSession.displayName =
              updateBody['displayName']?.toString() ?? desiredName;
          AuthSession.email =
              updateBody['email']?.toString() ?? AuthSession.email;
          AuthSession.idToken =
              updateBody['idToken']?.toString() ?? AuthSession.idToken;
        }
        final projectId = DefaultFirebaseOptions.currentPlatform.projectId;
        final updateFields = <String, dynamic>{};
        final updateMasks = <String>[];
        if (desiredName.isNotEmpty) {
          updateFields['name'] = {'stringValue': desiredName};
          updateMasks.add('name');
        }
        if (phone.isNotEmpty) {
          updateFields['phone'] = {'stringValue': phone};
          updateMasks.add('phone');
        }
        if (updateFields.isNotEmpty) {
        final uri = Uri.parse(
          'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users/${AuthSession.userId}?${updateMasks.map((field) => 'updateMask.fieldPaths=$field').join('&')}',
        );
        final body = {
          'fields': {
            ...updateFields,
          }
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
          throw Exception('Unable to update profile.');
        }
        AuthSession.displayName = desiredName;
        }
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('Not signed in.');
        }
        final currentName = user.displayName ?? '';
        final desiredName = name.isNotEmpty ? name : currentName;

        if (name.isNotEmpty && desiredName != currentName) {
          await user.updateDisplayName(desiredName);
        }

        final updateData = <String, dynamic>{};
        if (desiredName.isNotEmpty) {
          updateData['name'] = desiredName;
        }
        if (phone.isNotEmpty) {
          updateData['phone'] = phone;
        }
        if (updateData.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(updateData, SetOptions(merge: true));
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to save profile: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = _photoController.text.trim();
    ImageProvider? avatarImage;
    if (_pickedImageBytes != null) {
      avatarImage = MemoryImage(_pickedImageBytes!);
    } else if (_pickedImage != null && !kIsWeb) {
      avatarImage = FileImage(File(_pickedImage!.path));
    } else if (photoUrl.isNotEmpty) {
      avatarImage = NetworkImage(photoUrl);
    }
    return Scaffold(
      backgroundColor: kPaper,
      appBar: AppBar(
        backgroundColor: kBlush,
        foregroundColor: kInk,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Customize Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: kPeach.withOpacity(0.35),
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? const Icon(Icons.person, color: kInk, size: 40)
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image_outlined),
            label: const Text('Upload photo'),
          ),
          TextField(
            controller: _photoController,
            decoration: const InputDecoration(
              labelText: 'Profile photo URL',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone',
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isSaving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: kInk,
              foregroundColor: kPaper,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ),
      ),
    );
  }
}
