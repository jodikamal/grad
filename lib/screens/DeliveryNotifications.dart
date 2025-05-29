import 'package:flutter/material.dart';
import 'package:graduation/screens/ipadress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeliveryNotificationsPage extends StatefulWidget {
  @override
  _DeliveryNotificationsPageState createState() =>
      _DeliveryNotificationsPageState();
}

class _DeliveryNotificationsPageState extends State<DeliveryNotificationsPage> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final url = Uri.parse('http://$ip:3000/delivery/notifications');

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
      appBar: AppBar(title: Text('Delivery Notifications')),
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
