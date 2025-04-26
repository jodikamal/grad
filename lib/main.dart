import 'package:flutter/material.dart';
//import 'screens/HomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:graduation/notification_service.dart';
import 'firebase_options.dart'; // استيراد ملف الإعدادات
import 'screens/MainNavigation.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions
            .currentPlatform, // تهيئة Firebase باستخدام الإعدادات الخاصة بالمنصة
  );

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
          // This ensures we have a context after the MaterialApp is built
          NotificationService.init(context);
          return SplashScreen();
        },
      ),
      locale: const Locale('en', 'US'),
    );
  }
}
