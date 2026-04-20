import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/common_widgets.dart';
import 'private_chat_detail_screen.dart';

class PrivateChatsScreen extends StatefulWidget {
  const PrivateChatsScreen({super.key});
  
  @override
  State<PrivateChatsScreen> createState() => _PrivateChatsScreenState();
}

class _PrivateChatsScreenState extends State<PrivateChatsScreen> {
  List<dynamic>? _chats;
  bool _isLoading = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadChats();
  }
  
  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final chats = await appState.apiService.getPrivateChats();
      if (mounted) {
        setState(() {
          _chats = chats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _showCreateChatDialog() async {
    final nameController = TextEditingController();
    final membersController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Private Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Chat name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: membersController,
              decoration: const InputDecoration(
                hintText: 'Member IDs (comma-separated)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    
    if (result == true && nameController.text.trim().isNotEmpty) {
      try {
        final members = membersController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        
        final appState = Provider.of<AppState>(context, listen: false);
        await appState.apiService.createPrivateChat(
          nameController.text.trim(),
          members,
        );
        _loadChats();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Loading chats...');
    }
    
    if (_error != null) {
      return ErrorDisplay(message: _error!, onRetry: _loadChats);
    }
    
    return Scaffold(
      body: _chats == null || _chats!.isEmpty
          ? const Center(child: Text('No private chats yet'))
          : RefreshIndicator(
              onRefresh: _loadChats,
              child: ListView.builder(
                itemCount: _chats!.length,
                itemBuilder: (context, index) {
                  final chat = _chats![index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: const Icon(Icons.group),
                      title: Text(chat['name'] ?? ''),
                      subtitle: Text('${(chat['members'] as List?)?.length ?? 0} members'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PrivateChatDetailScreen(
                              chatId: chat['id'],
                              chatName: chat['name'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: Consumer<AppState>(
        builder: (context, appState, child) {
          if (!appState.verified) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: _showCreateChatDialog,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}
