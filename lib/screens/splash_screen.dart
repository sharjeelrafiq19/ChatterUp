import 'dart:async';
import 'dart:developer';

import 'package:chatter_up/api/apis.dart';
import 'package:chatter_up/auth/login_screen.dart';
import 'package:chatter_up/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:animated_splash_screen/animated_splash_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 3), () {

      if (APIs.auth.currentUser != null){
        log("\nUser: ${APIs.auth.currentUser}");
        //Navigate to Home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }else{
        //Navigate to Home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2c462b),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                height: 500,
                width: 500,
                child: const Center(
                  child: Image(
                    image: AssetImage("assets/images/ChatterUp-logos_transparent.png"),
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
