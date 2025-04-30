import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:graduation/notification_service.dart';
import 'firebase_options.dart'; // Import Firebase settings
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase initialization
  );

  // Optional: Wait a little for Firebase to be ready
  await Future.delayed(const Duration(seconds: 2));

  runApp(const GlamzyApp());
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
          // Initialize notification service
          NotificationService.init(context);
          return const SplashScreen(); // Initial screen
        },
      ),
      locale: const Locale('en', 'US'), // Set the default locale
      // إضافة المسارات هنا
    );
  }
}
