import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../screens/ipadress.dart';

class MessageService {
  static const String baseUrl = 'http://$ip:3000';

  // Fetch messages for a specific user
  Future<List<Message>> fetchMessages(int userId) async {
    try {
      final url = '$baseUrl/messages/$userId';
      print('DEBUG: Fetching messages from: $url');

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 30));

      print('DEBUG: Fetch messages response status: ${response.statusCode}');
      print('DEBUG: Fetch messages response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('DEBUG: Empty response body, returning empty list');
          return [];
        }

        try {
          final dynamic decodedData = json.decode(response.body);
          print('DEBUG: Decoded data type: ${decodedData.runtimeType}');

          if (decodedData is List) {
            print('DEBUG: Processing ${decodedData.length} messages');
            List<Message> messages = [];

            for (int i = 0; i < decodedData.length; i++) {
              try {
                final messageData = decodedData[i];
                print('DEBUG: Processing message $i: $messageData');
                messages.add(Message.fromJson(messageData));
              } catch (e) {
                print('ERROR: Failed to parse message $i: $e');
                // Continue processing other messages
              }
            }

            return messages;
          } else {
            print('ERROR: Expected List but got ${decodedData.runtimeType}');
            return [];
          }
        } catch (e) {
          print('ERROR: JSON decode failed: $e');
          print('ERROR: Response body was: ${response.body}');
          return [];
        }
      } else {
        throw Exception(
          'Failed to fetch messages: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('ERROR: Exception in fetchMessages: $e');
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
      final url = '$baseUrl/messages/send';
      final payload = {
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'is_admin': isAdmin ? 1 : 0,
        'sender_name': senderName,
      };

      print('DEBUG: Sending message to: $url');
      print('DEBUG: Payload: ${json.encode(payload)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      print('DEBUG: Send message response status: ${response.statusCode}');
      print('DEBUG: Send message response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          print('DEBUG: Successfully decoded response data');
          return Message.fromJson(data);
        } catch (e) {
          print('ERROR: Failed to decode response as JSON: $e');
          // If the server doesn't return proper JSON, create a message object
          return Message(
            messageId: 0, // Temporary ID
            senderId: senderId,
            receiverId: receiverId,
            content: content,
            timestamp: DateTime.now(),
            isAdmin: isAdmin,
            senderName: senderName,
            isRead: false,
          );
        }
      } else {
        throw Exception(
          'Failed to send message: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('ERROR: Exception in sendMessage: $e');
      throw Exception('Error sending message: $e');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(int userId, int senderId) async {
    try {
      final url = '$baseUrl/messages/mark-read';
      final payload = {'user_id': userId, 'sender_id': senderId};

      print('DEBUG: Marking messages as read: $url');
      print('DEBUG: Payload: ${json.encode(payload)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      print('DEBUG: Mark as read response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to mark messages as read: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('ERROR: Exception in markMessagesAsRead: $e');
      throw Exception('Error marking messages as read: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(int messageId) async {
    try {
      final url = '$baseUrl/messages/$messageId';
      print('DEBUG: Deleting message: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('DEBUG: Delete message response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to delete message: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('ERROR: Exception in deleteMessage: $e');
      throw Exception('Error deleting message: $e');
    }
  }

  // Get unread message count
  Future<int> getUnreadMessageCount(int userId) async {
    try {
      final url = '$baseUrl/messages/unread-count/$userId';
      print('DEBUG: Getting unread count from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('DEBUG: Unread count response status: ${response.statusCode}');
      print('DEBUG: Unread count response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['count'] ?? 0;
      } else {
        throw Exception(
          'Failed to get unread count: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('ERROR: Exception in getUnreadMessageCount: $e');
      throw Exception('Error getting unread count: $e');
    }
  }

  // Test server connectivity
  Future<bool> testServerConnection() async {
    try {
      final url =
          '$baseUrl/health'; // Assuming you have a health check endpoint
      print('DEBUG: Testing server connection: $url');

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      print('DEBUG: Server connection test status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('ERROR: Server connection test failed: $e');
      return false;
    }
  }
}
