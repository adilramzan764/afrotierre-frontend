import 'package:afrotierre/onboarding_screen.dart';
import 'package:afrotierre/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'constants.dart';

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(),
      initialRoute: splashScreen,
      title: "Premiers App",
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        splashScreen: (context) => SplashScreen(),
        onboardingScreen: (context) => const OnboardingScreen(),
      },
    );
  }
}
