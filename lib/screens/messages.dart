import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/message.dart';
import '../services/message_service.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageService _messageService = MessageService();

  List<Message> messages = [];
  int? userId;
  bool isAdmin = false;
  String? userName;
  Timer? _timer;
  bool _isLoading = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Set up periodic message fetching
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchMessages(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    setState(() {
      userId = prefs.getInt('userId');
      isAdmin = prefs.getBool('isAdmin') ?? false;
      userName = prefs.getString('userName');
    });
    if (userId != null) {
      await _fetchMessages();
      await _updateUnreadCount();
    }
  }

  Future<void> _updateUnreadCount() async {
    if (userId == null) return;
    try {
      final count = await _messageService.getUnreadMessageCount(userId!);
      setState(() {
        _unreadCount = count;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _fetchMessages() async {
    if (userId == null) return;

    try {
      setState(() => _isLoading = true);
      final fetchedMessages = await _messageService.fetchMessages(userId!);
      setState(() {
        messages = fetchedMessages;
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      });
      _scrollToBottom();
      await _updateUnreadCount();
    } catch (e) {
      _showErrorSnackBar('Error loading messages: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (userId == null || _messageController.text.trim().isEmpty) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    try {
      await _messageService.sendMessage(
        senderId: userId!,
        receiverId: 1, // Admin ID
        content: content,
        isAdmin: isAdmin,
        senderName: userName ?? 'Unknown',
      );
      await _fetchMessages();
    } catch (e) {
      _showErrorSnackBar('Error sending message: $e');
    }
  }

  Future<void> _deleteMessage(Message message) async {
    try {
      await _messageService.deleteMessage(message.messageId);
      await _fetchMessages();
    } catch (e) {
      _showErrorSnackBar('Error deleting message: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Chat with Admin'),
            if (_unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _unreadCount.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.purple[100],
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child:
                messages.isEmpty
                    ? Center(
                      child: Text(
                        'No messages yet.\nStart a conversation with admin!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMyMessage = message.senderId == userId;

                        return Dismissible(
                          key: Key(message.messageId.toString()),
                          direction:
                              isMyMessage
                                  ? DismissDirection.endToStart
                                  : DismissDirection.none,
                          onDismissed: (_) => _deleteMessage(message),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: Align(
                            alignment:
                                isMyMessage
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    isMyMessage
                                        ? Colors.purple[100]
                                        : Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    isMyMessage
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.senderName ?? 'Unknown',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isMyMessage
                                              ? Colors.purple[900]
                                              : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    message.content,
                                    style: TextStyle(
                                      color:
                                          isMyMessage
                                              ? Colors.purple[900]
                                              : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              isMyMessage
                                                  ? Colors.purple[900]
                                                  : Colors.black54,
                                        ),
                                      ),
                                      if (isMyMessage) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          message.isRead
                                              ? Icons.done_all
                                              : Icons.done,
                                          size: 16,
                                          color: Colors.purple[900],
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
