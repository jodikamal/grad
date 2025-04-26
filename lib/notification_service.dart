import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init(BuildContext context) async {
    // Request notification permission
    print("############");
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ Notification permission granted");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("⚠️ Provisional notification permission granted");
    } else {
      print("❌ Notification permission denied");
      return;
    }

    // Get and print FCM token
    String? token = await _messaging.getToken();
    if (token != null) {
      print("📱 FCM Token: $token");
    } else {
      print("❌ Failed to get FCM Token");
    }

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null && context.mounted) {
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: Text(notification.title ?? 'No Title'),
                content: Text(notification.body ?? 'No body'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
        );
      }
    });
  }
}
