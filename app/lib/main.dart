import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:icontrol/res/owner_colors.dart';
import 'package:icontrol/ui/auth/login/login.dart';
import 'package:icontrol/ui/auth/login/validation_code.dart';
import 'package:icontrol/ui/auth/recover_password/recover_password.dart';
import 'package:icontrol/ui/auth/register/register_address_form.dart';
import 'package:icontrol/ui/auth/register/register_company_data.dart';
import 'package:icontrol/ui/auth/register/register_owner_data.dart';
import 'package:icontrol/ui/intro/onboarding.dart';
import 'package:icontrol/ui/intro/splash.dart';
import 'package:icontrol/ui/main/checkout_flow/checkout.dart';
import 'package:icontrol/ui/main/checkout_flow/method_payment.dart';
import 'package:icontrol/ui/main/checkout_flow/sucess.dart';
import 'package:icontrol/ui/main/home.dart';
import 'package:icontrol/ui/main/menu/employees/employees.dart';
import 'package:icontrol/ui/main/menu/equips/brands/brands.dart';
import 'package:icontrol/ui/main/menu/equips/brands/models/models.dart';
import 'package:icontrol/ui/main/menu/equips/equipments.dart';
import 'package:icontrol/ui/main/menu/equips/fleets/fleets.dart';
import 'package:icontrol/ui/main/menu/payments/payments.dart';
import 'package:icontrol/ui/main/menu/user/profile.dart';
import 'package:icontrol/ui/main/notifications/notifications.dart';
import 'package:icontrol/ui/main/task/task_detail.dart';
import 'package:icontrol/ui/utilities/pdf_viewer.dart';

import 'config/notification_helper.dart';
import 'config/preferences.dart';
import 'config/useful.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  LocalNotification.showNotification(message);
  print("Handling a background message: $message");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Preferences.init();

  if (Platform.isAndroid) {
    await Firebase.initializeApp();
  } else if (Platform.isIOS){
    await Firebase.initializeApp(
      /*options: FirebaseOptions(
      apiKey: WSConstants.API_KEY,
      appId: WSConstants.APP_ID,
      messagingSenderId: WSConstants.MESSGING_SENDER_ID,
      projectId: WSConstants.PROJECT_ID,
    )*/);
  }

  LocalNotification.initialize();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    LocalNotification.showNotification(message);
    print('Mensagem recebida: ${message.data}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Mensagem abertaaaaaaaaa: ${message.data}');

  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MaterialApp(
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white, //fundo de todo app
      primarySwatch: Useful().getMaterialColor(OwnerColors.colorPrimary),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Useful().getMaterialColor(OwnerColors.colorPrimary)),
    ),
    debugShowCheckedModeBanner: false,
    title: "IControl",
    initialRoute:'/ui/splash',
    color: OwnerColors.colorPrimary,
    routes: {
      '/ui/splash': (context) => Splash(),
      '/ui/onboarding': (context) => Onboarding(),
      '/ui/login': (context) => Login(),
      '/ui/register_address_form': (context) => RegisterAddressForm(),
      '/ui/register_owner_data': (context) => RegisterOwnerData(),
      '/ui/register_company_data': (context) => RegisterCompanyData(),
      '/ui/home': (context) => Home(),
      '/ui/profile': (context) => Profile(),
      '/ui/pdf_viewer': (context) => PdfViewer(),
      '/ui/method_payment': (context) => MethodPayment(),
      '/ui/payments': (context) => Payments(),
      '/ui/success': (context) => Success(),
      '/ui/notifications': (context) => Notifications(),
      '/ui/recover_password': (context) => RecoverPassword(),
      '/ui/employees': (context) => Employees(),
      '/ui/checkout': (context) => Checkout(),
      '/ui/equipments': (context) => Equipments(),
      '/ui/fleets': (context) => Fleets(),
      '/ui/brands': (context) => Brands(),
      '/ui/models': (context) => Models(),
      '/ui/task_detail': (context) => TaskDetail(),
      '/ui/validation_code': (context) => ValidationCode(),


    },
  ));
}