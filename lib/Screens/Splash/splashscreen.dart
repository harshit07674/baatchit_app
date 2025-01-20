import 'dart:async';

import 'package:baatchit/Screens/Home/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:baatchit/Screens/OnBoarding/onboardingscreen.dart';
import 'package:baatchit/Widgets/uihelper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>FirebaseAuth.instance.currentUser!=null?HomeScreen():OnBoardingScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/whatsapp 1.png"),
            SizedBox(
              height: 20,
            ),
            UiHelper.CustomText(text: "WhatsApp", height: 18,fontweight: FontWeight.bold)
          ],
        ),
      ),
    );
  }
}
