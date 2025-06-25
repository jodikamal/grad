import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../screens/ipadress.dart';

class MessageService {
  static const String baseUrl = 'http://$ip:3000';

  // Fetch messages for a specific user
  Future<List<Message>> fetchMessages(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/messages/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  // Send a new message
  Future<Message> sendMessage({
    required int senderId,
    required int receiverId,
    required String content,
    required bool isAdmin,
    required String senderName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'content': content,
          'is_admin': isAdmin ? 1 : 0,
          'sender_name': senderName,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Message.fromJson(data);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(int userId, int senderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages/mark-read'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId, 'sender_id': senderId}),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to mark messages as read: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error marking messages as read: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(int messageId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/messages/$messageId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting message: $e');
    }
  }

  // Get unread message count
  Future<int> getUnreadMessageCount(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/unread-count/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['count'] ?? 0;
      } else {
        throw Exception('Failed to get unread count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting unread count: $e');
    }
  }
}
