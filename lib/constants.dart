import 'package:flutter/material.dart';

const splashScreen = "/SplashScreen";
const onboardingScreen = "/OnboardingScreen";
const createAccountBuyerScreen = "/CreateAccountBuyerScreen";
const createAccountSellerScreen = "/CreateAccountSellerScreen";
const signInAccountBuyerScreen = "/SignInAccountBuyerScreen";
const signInAccountSellerScreen = "/SignInAccountSellerScreen";
const bottomNavigationScreen = "/BottomNavigationScreen";

Color primaryColor = const Color(0xFFEFAE30);
Color secondaryColor = const Color(0xFF000000);
int currentIndex = 0;
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
var keyboardVisible = false;
