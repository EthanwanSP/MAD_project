import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app_theme.dart';
import 'package:lottie/lottie.dart';
import 'back_icon_button.dart';
import 'auth_session.dart';
import 'firebase_options.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  final TextEditingController _emailController = TextEditingController();
  bool _isUpdating = false;

  Future<void> _updatePassword() async {
    final email = _emailController.text.trim();

    setState(() {
      _isUpdating = true;
    });

    try {
      if (email.isEmpty) {
        throw Exception('Please enter your email.');
      }
      if (kIsWeb) {
        final apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;
        final resetUri = Uri.parse(
          'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$apiKey',
        );
        final resetResponse = await http.post(
          resetUri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'requestType': 'PASSWORD_RESET',
            'email': email,
          }),
        );
        if (resetResponse.statusCode != 200) {
          final errorBody =
              jsonDecode(resetResponse.body) as Map<String, dynamic>?;
          final message =
              errorBody?['error']?['message']?.toString() ??
                  'Unable to send reset email.';
          throw Exception(message);
        }
      } else {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      }

      if (mounted) {
        const message = 'Password reset email sent';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pushNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to update password: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  SquareBackButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Lottie.network(
                          'https://lottie.host/77b46cf4-3801-4a67-9785-2bc7a42b637f/2puIPi2z0L.json',
                          width: 150,
                          height: 150,
                        ),
                        Text(
                          "Forgot password?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: kInk,
                          ),
                        ),
                        Text(
                          "We got you!",
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
                            controller: _emailController,
                            obscureText: false,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter registered email',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: kInk,
                            foregroundColor: kPaper,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          onPressed: _isUpdating ? null : _updatePassword,
                          child: _isUpdating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Confirm!",
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
