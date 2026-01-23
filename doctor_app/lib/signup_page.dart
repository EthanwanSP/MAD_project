import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'home_shell.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _hide = true;
  final TextEditingController _newemailcontroller = TextEditingController();
  final TextEditingController _newpasswordcontorller = TextEditingController();

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
              child: FloatingActionButton(
                onPressed: () {
                  
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
                backgroundColor: kInk,
                foregroundColor: Colors.white,
                child: Icon(Icons.arrow_back),
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
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const HomeShell(),
                            ),
                          );
                        },
                        child: const Row(
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
                    ],
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
