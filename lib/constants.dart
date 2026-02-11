import 'package:flutter/material.dart';

const splashScreen = "/SplashScreen";
const onboardingScreen = "/OnboardingScreen";
const createAccountBuyerScreen = "/CreateAccountBuyerScreen";
const createAccountSellerScreen = "/CreateAccountSellerScreen";
const signInAccountBuyerScreen = "/SignInAccountBuyerScreen";
const signInAccountSellerScreen = "/SignInAccountSellerScreen";
const searchScreen = "/SearchScreen";
const bottomNavigationScreen = "/BottomNavigationScreen";
const filtersScreen = "/FiltersScreen";
const categoriesScreen = "/CategoriesScreen";
const productDetailsScreen = "/ProductDetailsScreen";
const cartScreen = "/CartScreen";
const checkoutScreen = "/CheckoutScreen";
const paymentSuccessfulScreen = "/PaymentSuccessfulScreen";
const orderDetailScreen = "/OrderDetailScreen";
const myOrdersScreen = "/MyOrdersScreen";
const refundScreen = "/RefundScreen";
const orderCompletedDetailScreen = "/OrderCompletedDetailScreen";
const changePasswordScreen = "/ChangePasswordScreen";
const personalInformationScreen = "/PersonalInformationScreen";
const shippingAddressScreen = "/ShippingAddressScreen";
const newShippingAddressScreen = "/NewShippingAddressScreen";
const notificationScreen = "/NotificationScreen";
const paymentMethodScreen = "/PaymentMethodScreen";
const addCardScreen = "/AddCardScreen";

// vendor
const vendorBottomNavigationScreen = "/VendorBottomNavigationScreen";
const vendorSalesStatisticsScreen = "/VendorSalesStatisticsScreen";
const vendorCommissionScreen = "/VendorCommissionScreen";
const vendorNotificationScreen = "/VendorNotificationScreen";
const vendorSubcriptionPlanScreen = "/VendorSubcriptionPlanScreen";
const vendorProductDetailsScreen = "/VendorProductDetailsScreen";
const vendorTransactionHistoryScreen = "/VendorTransactionHistoryScreen";
const vendorWithdrawalScreen = "/VendorWithdrawalScreen";
const vendorWithdrawalConfirmScreen = "/VendorWithdrawalConfirmScreen";
const vendorAddProductScreen = "/VendorAddProductScreen";
const vendorOrderDetailsScreen = "/VendorOrderDetailsScreen";

Color primaryColor = const Color(0xFFEFAE30);
Color secondaryColor = const Color(0xFF000000);
int currentIndex = 0;
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
var keyboardVisible = false;
String selectedWalletType = 'Buyer';
