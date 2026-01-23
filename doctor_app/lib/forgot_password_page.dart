import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'home_shell.dart';
import 'package:lottie/lottie.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  bool _hide = true;
  bool _ishidden = true;
  final TextEditingController _newpasswordcontorller = TextEditingController();
  final TextEditingController _confirmpasswordcontorller = TextEditingController();

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
                      Lottie.network('https://lottie.host/77b46cf4-3801-4a67-9785-2bc7a42b637f/2puIPi2z0L.json',
                        width: 150,
                        height: 150),
                      
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
                          controller: _newpasswordcontorller,
                          obscureText: _ishidden,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'New password',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _ishidden = !_ishidden;
                                });
                              },
                              icon: Icon(
                                _ishidden
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
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
                          controller: _confirmpasswordcontorller,
                          obscureText: _hide,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Confirm password',
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
          ],
        ),
      ),
    );
  }
}