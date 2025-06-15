import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:graduation/notification_service.dart';
import 'firebase_options.dart'; // Import Firebase settings
import 'screens/splash_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔄 Background message received: ${message.messageId}");
}

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize Stripe
    Stripe.publishableKey =
        'pk_test_51PDnd7BlhJuWT9ZMJfbJ3i7U3Z1G0GOtrEiIJeSARJ0tqlCJhO7V5Pe1lT8YwtMso1AvF3knxiPpkkSIEXEzCwMR00J0FDPvZv';
    await Stripe.instance.applySettings();

    // Add a small delay if needed for initialization
    await Future.delayed(const Duration(seconds: 2));

    runApp(const GlamzyApp());
  } catch (e) {
    print('Initialization error: $e');
    rethrow;
  }
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
