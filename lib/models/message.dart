class Message {
  final int messageId;
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime timestamp;
  final bool isAdmin;
  bool isRead;
  final String senderName;

  Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isAdmin,
    this.isRead = false,
    required this.senderName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    try {
      // Helper function to safely convert to int
      int _safeInt(dynamic value, {int defaultValue = 0}) {
        if (value == null) return defaultValue;
        if (value is int) return value;
        if (value is String) {
          final parsed = int.tryParse(value);
          return parsed ?? defaultValue;
        }
        return defaultValue;
      }

      // Helper function to safely convert to bool
      bool _safeBool(dynamic value, {bool defaultValue = false}) {
        if (value == null) return defaultValue;
        if (value is bool) return value;
        if (value is int) return value == 1;
        if (value is String) {
          final lower = value.toLowerCase();
          return lower == 'true' || lower == '1';
        }
        return defaultValue;
      }

      // Helper function to safely convert to String
      String _safeString(dynamic value, {String defaultValue = ''}) {
        if (value == null) return defaultValue;
        return value.toString();
      }

      // Helper function to safely parse DateTime
      DateTime _safeDateTime(dynamic value) {
        if (value == null) return DateTime.now();
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (e) {
            print('ERROR: Failed to parse timestamp: $value');
            return DateTime.now();
          }
        }
        return DateTime.now();
      }

      print('DEBUG: Parsing JSON: $json');

      return Message(
        messageId: _safeInt(json['message_id']),
        senderId: _safeInt(json['sender_id']),
        receiverId: _safeInt(json['receiver_id']),
        content: _safeString(json['content'], defaultValue: 'No content'),
        timestamp: _safeDateTime(json['timestamp']),
        isAdmin: _safeBool(json['is_admin']),
        isRead: _safeBool(json['is_read']),
        senderName: _safeString(
          json['sender_name'],
          defaultValue: 'Unknown User',
        ),
      );
    } catch (e) {
      print('ERROR: Failed to parse Message from JSON: $e');
      print('ERROR: Problematic JSON: $json');

      // Return a default message to prevent crashes
      return Message(
        messageId: 0,
        senderId: 0,
        receiverId: 0,
        content: 'Error loading message',
        timestamp: DateTime.now(),
        isAdmin: false,
        isRead: false,
        senderName: 'System',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'is_admin': isAdmin ? 1 : 0,
      'is_read': isRead ? 1 : 0,
      'sender_name': senderName,
    };
  }

  @override
  String toString() {
    return 'Message(id: $messageId, from: $senderId, to: $receiverId, content: "$content", time: $timestamp, isAdmin: $isAdmin, isRead: $isRead, sender: "$senderName")';
  }
}
