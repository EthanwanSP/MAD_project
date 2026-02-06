import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:doctor_app/firebase_options.dart';
import 'auth_session.dart';
import 'app_theme.dart';
import 'back_icon_button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _hide = true;
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _newemailcontroller = TextEditingController();
  final TextEditingController _newpasswordcontorller = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _newemailcontroller.dispose();
    _newpasswordcontorller.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _newemailcontroller.text.trim();
    final password = _newpasswordcontorller.text;

    setState(() {
      _isLoading = true;
    });

    try {
      if (kIsWeb) {
        final apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;
        final uri = Uri.parse(
          'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
        );
        final response = await http.post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }),
        );
        if (response.statusCode != 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final message =
              body['error']?['message']?.toString() ?? 'Sign up failed.';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red.shade400,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
          return;
        }

        final body = jsonDecode(response.body) as Map<String, dynamic>;
        AuthSession.idToken = body['idToken']?.toString();
        AuthSession.userId = body['localId']?.toString();
        AuthSession.email = email;
        if (AuthSession.idToken != null && name.isNotEmpty) {
          final updateUri = Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:update?key=$apiKey',
          );
          await http.post(
            updateUri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'idToken': AuthSession.idToken,
              'displayName': name,
              'returnSecureToken': true,
            }),
          );
          AuthSession.displayName = name;
        }
        if (AuthSession.userId != null) {
          final projectId = DefaultFirebaseOptions.currentPlatform.projectId;
          final userUri = Uri.parse(
            'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users/${AuthSession.userId}',
          );
          final userBody = {
            'fields': {
              'userId': {'stringValue': AuthSession.userId},
              'name': {'stringValue': name},
              'email': {'stringValue': email},
              'createdAt': {
                'timestampValue': DateTime.now().toUtc().toIso8601String()
              },
            },
          };
          await http.patch(
            userUri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AuthSession.idToken}',
            },
            body: jsonEncode(userBody),
          );
        }

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Sign up failed.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: $e'),
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
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kPeach, kBlush],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SquareBackButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/little_doctor.png',
                          width: 150,
                          height: 150,
                        ),
                        Text(
                          "Health awaits!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: kInk,
                          ),
                        ),
                        Text(
                          "Sign up now!",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 30),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: kInk, width: 2.5),
                            borderRadius: BorderRadius.circular(60),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: kInk,
                                blurRadius: 1,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Full name',
                              prefixIcon: const Icon(Icons.person_outline),
                              suffixIcon: _nameController.text.isEmpty
                                  ? Container(width: 0)
                                  : IconButton(
                                      onPressed: () {
                                        _nameController.clear();
                                      },
                                      icon: Icon(Icons.close),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: kInk, width: 2.5),
                            borderRadius: BorderRadius.circular(60),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: kInk,
                                blurRadius: 1,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _newemailcontroller,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Email or mobile number',
                              prefixIcon: const Icon(Icons.mail_outline),
                              suffixIcon: _newemailcontroller.text.isEmpty
                                  ? Container(width: 0)
                                  : IconButton(
                                      onPressed: () {
                                        _newemailcontroller.clear();
                                      },
                                      icon: Icon(Icons.close),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60),
                            border: Border.all(color: kInk, width: 2.5),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: kInk,
                                blurRadius: 1,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _newpasswordcontorller,
                            obscureText: _hide,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _hide = !_hide;
                                  });
                                },
                                icon: Icon(
                                  _hide
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 50),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: kInk,
                            foregroundColor: kPaper,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          onPressed: _isLoading ? null : _signUp,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "I'm Done!",
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        SizedBox(height: 24),
                      ],
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
