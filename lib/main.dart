import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:share_bits/controllers/call_controller.dart';
import 'package:share_bits/controllers/socket_controller.dart';
import 'package:share_bits/services/socket_service.dart';
import 'package:share_bits/services/web_rtc_service.dart';
import 'firebase_options.dart';
import 'package:share_bits/screens/home_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // This is running on a separate isolate
  // await Firebase.initializeApp();

  print("Handling a background message: ${message.data}");
}

Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
  print('Got a message whilst in the foreground!');
  print('Message data: ${message.data}');

  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Init Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FCM Permission
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // Handle FCM Token
  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    log(fcmToken);
  }).onError((err) {
    log(err.toString());
  });

  // Handle Background Message
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Handle Foreground Message
  FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);

  // Main App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialBinding: BindingsBuilder(() {
          // Services
          Get.put(SocketService());
          Get.put(WebRtcService());

          // Controllers
          Get.put(SocketController());
          Get.put(CallController());
        }),
        initialRoute: '/home',
        routes: {'/home': (context) => const HomeScreen()});
  }
}
