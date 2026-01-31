import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:doctor_app/firebase_options.dart';
import 'auth_session.dart';
import 'package:lottie/lottie.dart';

import 'app_theme.dart';
import 'home_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool _hidden = true;
  bool _isLoading = false;
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontorller = TextEditingController();

  @override
  void dispose() {
    _emailcontroller.dispose();
    _passwordcontorller.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailcontroller.text.trim();
    final password = _passwordcontorller.text;

    setState(() {
      _isLoading = true;
    });

    try {
      if (kIsWeb) {
        final apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;
        final uri = Uri.parse(
          'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey',
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
              body['error']?['message']?.toString() ?? 'Login failed.';
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
        final lookupUri = Uri.parse(
          'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=$apiKey',
        );
        final lookupResponse = await http.post(
          lookupUri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': AuthSession.idToken}),
        );
        if (lookupResponse.statusCode == 200) {
          final lookupBody =
              jsonDecode(lookupResponse.body) as Map<String, dynamic>;
          final users = lookupBody['users'];
          if (users is List && users.isNotEmpty) {
            final displayName = users.first['displayName']?.toString();
            AuthSession.displayName = displayName;
          }
        }
        if (AuthSession.displayName == null || AuthSession.displayName!.isEmpty) {
          AuthSession.displayName = email.split('@').first;
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const HomeShell(),
            ),
          );
        }
        return;
      }

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const HomeShell(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Login failed.'),
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
            content: Text('Login failed: $e'),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kBlush, kPeach, kPaper],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.network('https://lottie.host/ef347e76-39ef-429b-afc9-985cd90a7189/1lpuwAfKUM.json',
                width: 200,
                height: 200),
                SizedBox(height: 30),
                Text(
                  'Feeling unwell?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your doctor visits, queues, and consults with us now!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kPaper,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: kInk,
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailcontroller,
                        decoration: InputDecoration(
                          hintText: 'Email or mobile number',
                          prefixIcon: const Icon(Icons.mail_outline),
                          suffixIcon:  _emailcontroller.text.isEmpty? Container(width: 0):IconButton(onPressed: (){
                            _emailcontroller.clear();
                          },  icon: Icon(Icons.close))
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordcontorller,
                        obscureText: _hidden,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(onPressed: (){
                            setState(() {
                              _hidden = !_hidden;
                            });
                          }, icon: Icon(_hidden? Icons.visibility_off_outlined:Icons.visibility_outlined))
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {Navigator.pushNamed(context, '/forgotPassword');},
                            child: const Text('Forgot password?'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 250,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: kInk,
                            foregroundColor: kPaper,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          onPressed: _isLoading ? null : _signIn,
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
                                      "Let's Go!",
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.login, size: 20),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New here?',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    TextButton(
                      onPressed: () {Navigator.pushNamed(context, '/signUp');},
                      child: const Text(
                        'Create account',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: kInk.withOpacity(0.3),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kInk.withOpacity(0.6),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: kInk.withOpacity(0.3),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 250,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/google-logo.png',
                        height: 25),
                        const SizedBox(width: 12),
                        Text(
                          'Sign in with Google',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
