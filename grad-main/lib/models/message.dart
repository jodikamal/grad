class Message {
  final int messageId;
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime timestamp;
  final bool isAdmin;
  final String? senderName;
  final bool isRead;

  Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isAdmin,
    this.senderName,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isAdmin: json['is_admin'] == 1,
      senderName: json['sender_name'],
      isRead: json['is_read'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'is_admin': isAdmin ? 1 : 0,
      'sender_name': senderName,
      'is_read': isRead ? 1 : 0,
    };
  }

  Message copyWith({
    int? messageId,
    int? senderId,
    int? receiverId,
    String? content,
    DateTime? timestamp,
    bool? isAdmin,
    String? senderName,
    bool? isRead,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isAdmin: isAdmin ?? this.isAdmin,
      senderName: senderName ?? this.senderName,
      isRead: isRead ?? this.isRead,
    );
  }
}
