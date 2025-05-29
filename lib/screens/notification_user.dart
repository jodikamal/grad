import 'package:flutter/material.dart';
import 'package:graduation/screens/ipadress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotificationsPage extends StatefulWidget {
  @override
  _UserNotificationsPageState createState() => _UserNotificationsPageState();
}

class _UserNotificationsPageState extends State<UserNotificationsPage> {
  List<dynamic> notifications = [];
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserIdAndFetch();
  }

  Future<void> loadUserIdAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      print('❌ user_id is null');
      return;
    }

    print('Fetching notifications for userId: $userId');
    await fetchNotifications(userId.toString()); // Add this line
  }

  Future<void> fetchNotifications(String userId) async {
    print('Fetching notifications for userId: $userId');
    final url = Uri.parse('http://$ip:3000/delivery/notifications/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          notifications = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print('Failed to load notifications');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Notifications')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? Center(child: Text('No notifications available.'))
              : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(notif['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notif['body']),
                          SizedBox(height: 5),
                          Text(
                            'Status: ${notif['status']}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            'Time: ${notif['timestamp']}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
