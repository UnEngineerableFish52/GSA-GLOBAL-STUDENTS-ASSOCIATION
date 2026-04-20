import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/common_widgets.dart';

class GlobalChatScreen extends StatefulWidget {
  const GlobalChatScreen({super.key});
  
  @override
  State<GlobalChatScreen> createState() => _GlobalChatScreenState();
}

class _GlobalChatScreenState extends State<GlobalChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  
  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Listen for messages
    appState.socketService.onMessage((data) {
      if (mounted) {
        setState(() {
          _messages.add(data as Map<String, dynamic>);
        });
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
  }
  
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    final appState = Provider.of<AppState>(context, listen: false);
    appState.socketService.sendMessage(text);
    _messageController.clear();
  }
  
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentUserId = appState.user?['id'];
    
    return Column(
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
    );
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
