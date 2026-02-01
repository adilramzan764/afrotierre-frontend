import 'package:flutter/material.dart';

const splashScreen = "/SplashScreen";
const onboardingScreen = "/OnboardingScreen";

Color primaryColor = const Color(0xFFEFAE30);
Color secondaryColor = const Color(0xFF000000);
int currentIndex = 0;
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
var keyboardVisible = false;
