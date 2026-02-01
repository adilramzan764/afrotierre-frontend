import 'dart:async';

import 'package:flutter/material.dart';

import 'constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  statusCheck() {
    Timer(const Duration(seconds: 2), () {
      Navigator.pushNamed(context, onboardingScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/splash_logo.png',
                  width: constraints.maxWidth * 0.7,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
