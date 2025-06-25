// lib/services/messaging_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../screens/ipadress.dart';

class MessagingService {
  final _messagesController = StreamController<List<Message>>.broadcast();
  Timer? _timer;

  Stream<List<Message>> get messagesStream => _messagesController.stream;

  void startFetchingMessages(int userId) {
    // Initial fetch
    _fetchAndPushMessages(userId);

    // Set up periodic fetching
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchAndPushMessages(userId);
    });
  }

  Future<void> _fetchAndPushMessages(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://$ip:3000/messages/$userId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final messages = data.map((json) => Message.fromJson(json)).toList();
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        if (!_messagesController.isClosed) {
          _messagesController.add(messages);
        }
      }
    } catch (e) {
      _messagesController.addError('Failed to load messages: $e');
    }
  }

  Future<void> sendMessage({
    required int senderId,
    required String content,
    required String? senderName,
    required bool isAdmin,
  }) async {
    // Your http.post logic here
    // ...
  }

  void dispose() {
    _timer?.cancel();
    _messagesController.close();
  }
}
