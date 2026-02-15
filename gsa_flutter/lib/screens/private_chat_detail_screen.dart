import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/common_widgets.dart';

class PrivateChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String chatName;
  
  const PrivateChatDetailScreen({
    super.key,
    required this.chatId,
    required this.chatName,
  });
  
  @override
  State<PrivateChatDetailScreen> createState() => _PrivateChatDetailScreenState();
}

class _PrivateChatDetailScreenState extends State<PrivateChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  
  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Join the chat
    appState.socketService.joinPrivateChat(widget.chatId);
    
    // Listen for private messages
    appState.socketService.onPrivateMessage((data) {
      if (mounted) {
        final messageData = data as Map<String, dynamic>;
        if (messageData['chatId'] == widget.chatId) {
          setState(() {
            _messages.add(messageData['message'] as Map<String, dynamic>);
          });
        }
      }
    });
    
    // Listen for history
    appState.socketService.onHistory((data) {
      if (mounted && data is List) {
        setState(() {
          _messages.clear();
          _messages.addAll(data.cast<Map<String, dynamic>>());
        });
      }
    });
    
    _loadMessages();
  }
  
  Future<void> _loadMessages() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final response = await appState.apiService.getPrivateChatMessages(widget.chatId);
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll((response['messages'] as List).cast<Map<String, dynamic>>());
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading messages: $e')),
        );
      }
    }
  }
  
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    final appState = Provider.of<AppState>(context, listen: false);
    appState.socketService.sendPrivateMessage(widget.chatId, text);
    _messageController.clear();
  }
  
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentUserId = appState.user?['id'];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatName),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return MessageBubble(
                        text: msg['text'] ?? '',
                        userId: msg['userId'] ?? '',
                        timestamp: msg['timestamp'] ?? '',
                        isCurrentUser: msg['userId'] == currentUserId,
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.socketService.leavePrivateChat(widget.chatId);
    _messageController.dispose();
    super.dispose();
  }
}
