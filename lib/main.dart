import 'package:deliveryboy_multivendor/Screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Helper/color.dart';
import 'Helper/constant.dart';
import 'Helper/push_notification_service.dart';
import 'Screens/Splash/splash.dart';
import 'dart:io' show Platform;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // status bar color
    systemNavigationBarColor: Colors.transparent,
  ));
  final pushNotificationService = PushNotificationService();
  pushNotificationService.initialise();
  FirebaseMessaging.onBackgroundMessage(myForgroundMessageHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      builder: (context, child) {
        return MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: Platform.isAndroid? 1 : 1.1), child: child!);
      },
      theme: ThemeData(
        primarySwatch: primary_app,
        fontFamily: 'opensans',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Splash(),
        '/home': (context) => Home(),
      },
    );  
  }
}
