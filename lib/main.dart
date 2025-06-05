import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:graduation/notification_service.dart';
import 'firebase_options.dart'; // Import Firebase settings
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase initialization
  );

  Stripe.publishableKey =
      'pk_test_51PDnd7BlhJuWT9ZMJfbJ3i7U3Z1G0GOtrEiIJeSARJ0tqlCJhO7V5Pe1lT8YwtMso1AvF3knxiPpkkSIEXEzCwMR00J0FDPvZv';
  await Stripe.instance.applySettings();

  await Future.delayed(const Duration(seconds: 2));
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const GlamzyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔄 Background message received: ${message.messageId}");
}

class GlamzyApp extends StatelessWidget {
  const GlamzyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glamzy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) {
          //
          NotificationService.init(context);
          return const SplashScreen(); //
        },
      ),
      locale: const Locale('en', 'US'), //
    );
  }
}
