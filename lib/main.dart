import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import 'Constants/StripeKeys.dart';
import 'Services/NotificationProvider.dart';
import 'View/Onboarding_Screens/splash_screen.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Stripe
    Stripe.publishableKey = StripeKeys.getPublishableKey();
    await Stripe.instance.applySettings();
    print('✅ Stripe initialized successfully in main');
  } catch (e) {
    print('❌ Failed to initialize Stripe in main: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        // ... other providers
      ],
      child: MaterialApp(
        title: "Afrotierre",
        debugShowCheckedModeBanner: false,
        builder: EasyLoading.init(),
        home:  SplashScreen(),
        theme: ThemeData(
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}