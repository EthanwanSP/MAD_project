import 'package:doctor_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CallingPage extends StatelessWidget {
  const CallingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(color: kInk),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Lottie.network(
              'https://lottie.host/e81ab329-e748-4c34-8eae-3e56e4814124/u5tja8U91n.json',
              width: double.infinity,
              height: 300
            ),
            SizedBox(height: 20,),
            Text(
              'Calling...',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            const Spacer(),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(3),
                      backgroundColor: kInk
                    ),
                    child: Icon(Icons.volume_off, color: Colors.white, size: 40),
                  ),
                  SizedBox(width: 10,),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/teleconsult');},
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(15),
                      backgroundColor: Colors.red,
                    ),
                    child: Icon(Icons.call_end, color: Colors.white, size: 40),
                  ),
                  SizedBox(width: 10,),
                  ElevatedButton(
                    onPressed: () {
                     },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(3),
                      backgroundColor: kInk
                    ),
                    child: Icon(Icons.video_call_sharp, color: Colors.white, size: 40),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
