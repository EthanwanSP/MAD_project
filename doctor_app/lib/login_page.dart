import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  void initState() {
    super.initState();
  }

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
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        final user = credential.user;
        if (user != null) {
          AuthSession.userId = user.uid;
          AuthSession.email = user.email ?? email;
          AuthSession.displayName =
              (user.displayName != null &&
                      user.displayName!.trim().isNotEmpty)
                  ? user.displayName!
                  : email.split('@').first;
          AuthSession.idToken = await user.getIdToken();
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
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
                          hintText: 'Email',
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
                const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
