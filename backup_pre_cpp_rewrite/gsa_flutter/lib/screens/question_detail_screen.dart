import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/common_widgets.dart';

class QuestionDetailScreen extends StatefulWidget {
  final String questionId;
  
  const QuestionDetailScreen({super.key, required this.questionId});
  
  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  Map<String, dynamic>? _question;
  bool _isLoading = false;
  String? _error;
  final TextEditingController _replyController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }
  
  Future<void> _loadQuestion() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final question = await appState.apiService.getQuestion(widget.questionId);
      if (mounted) {
        setState(() {
          _question = question;
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
  
  Future<void> _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.apiService.replyToQuestion(widget.questionId, text);
      _replyController.clear();
      _loadQuestion();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Question')),
        body: const LoadingIndicator(message: 'Loading question...'),
      );
    }
    
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Question')),
        body: ErrorDisplay(message: _error!, onRetry: _loadQuestion),
      );
    }
    
    if (_question == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Question')),
        body: const Center(child: Text('Question not found')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('Question')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _question!['text'] ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Asked by: ${_question!['userId'] ?? 'Unknown'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: (_question!['replies'] as List?)?.isEmpty ?? true
                ? const Center(child: Text('No replies yet'))
                : ListView.builder(
                    itemCount: (_question!['replies'] as List).length,
                    itemBuilder: (context, index) {
                      final reply = (_question!['replies'] as List)[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text(reply['text'] ?? ''),
                          subtitle: Text('By: ${reply['userId'] ?? 'Unknown'}'),
                        ),
                      );
                    },
                  ),
          ),
          Consumer<AppState>(
            builder: (context, appState, child) {
              if (!appState.verified) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('You must be verified to reply'),
                );
              }
              
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        decoration: const InputDecoration(hintText: 'Your reply...'),
                        onSubmitted: (_) => _submitReply(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _submitReply,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }
}
