import 'package:afrotierre/Buyers_Screens/add_card_screen.dart';
import 'package:afrotierre/Buyers_Screens/bottom_navigation_screen.dart'
    as bottom_from_buyer;
import 'package:afrotierre/Buyers_Screens/change_password_screen.dart';
import 'package:afrotierre/Buyers_Screens/checkout_screen.dart';
import 'package:afrotierre/Buyers_Screens/filters_screen.dart';
import 'package:afrotierre/Buyers_Screens/my_orders_screen.dart';
import 'package:afrotierre/Buyers_Screens/new_shipping_address_screen.dart';
import 'package:afrotierre/Buyers_Screens/notification_screen.dart';
import 'package:afrotierre/Buyers_Screens/order_completed_detail_screen.dart';
import 'package:afrotierre/Buyers_Screens/order_detail_screen.dart';
import 'package:afrotierre/Buyers_Screens/payment_method_screen.dart';
import 'package:afrotierre/Buyers_Screens/payment_successful_screen.dart';
import 'package:afrotierre/Buyers_Screens/personal_information_screen.dart';
import 'package:afrotierre/Buyers_Screens/product_details_screen.dart';
import 'package:afrotierre/Buyers_Screens/refund_screen.dart';
import 'package:afrotierre/Buyers_Screens/search_screen.dart';
import 'package:afrotierre/Buyers_Screens/shipping_address_screen.dart';
import 'package:afrotierre/Onboarding_Screens/create_account_buyer.dart';
import 'package:afrotierre/Onboarding_Screens/create_account_seller.dart';
import 'package:afrotierre/Onboarding_Screens/onboarding_screen.dart';
import 'package:afrotierre/Onboarding_Screens/sign_in_account_buyer.dart';
import 'package:afrotierre/Onboarding_Screens/sign_in_account_seller.dart';
import 'package:afrotierre/Onboarding_Screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'Buyers_Screens/cart_screen.dart' show CartScreen;
import 'Buyers_Screens/categories_screen.dart' show CategoriesScreen;
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
        createAccountBuyerScreen: (context) => const CreateAccountBuyerScreen(),
        createAccountSellerScreen: (context) =>
            const CreateAccountSellerScreen(),
        signInAccountBuyerScreen: (context) => const SignInAccountBuyerScreen(),
        signInAccountSellerScreen: (context) =>
            const SignInAccountSellerScreen(),
        bottomNavigationScreen: (context) =>
            const bottom_from_buyer.BottomNavigationScreen(),
        searchScreen: (context) => const SearchScreen(),
        filtersScreen: (context) => const FiltersScreen(),
        categoriesScreen: (context) => const CategoriesScreen(),
        productDetailsScreen: (context) => const ProductDetailsScreen(),
        cartScreen: (context) => const CartScreen(),
        checkoutScreen: (context) => const CheckoutScreen(),
        paymentSuccessfulScreen: (context) => const PaymentSuccessfulScreen(),
        orderDetailScreen: (context) => const OrderDetailScreen(),
        myOrdersScreen: (context) => const MyOrdersScreen(),
        refundScreen: (context) => const RefundScreen(),
        orderCompletedDetailScreen: (context) =>
            const OrderCompletedDetailScreen(),
        changePasswordScreen: (context) => const ChangePasswordScreen(),
        personalInformationScreen: (context) =>
            const PersonalInformationScreen(),
        shippingAddressScreen: (context) => const ShippingAddressScreen(),
        newShippingAddressScreen: (context) => const NewShippingAddressScreen(),
        notificationScreen: (context) => const NotificationScreen(),
        paymentMethodScreen: (context) => const PaymentMethodScreen(),
        addCardScreen: (context) => const AddCardScreen(),
      },
    );
  }
}
