import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/common_widgets.dart';
import 'question_detail_screen.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});
  
  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  List<dynamic>? _questions;
  bool _isLoading = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }
  
  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final questions = await appState.apiService.getQuestions();
      if (mounted) {
        setState(() {
          _questions = questions;
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
  
  Future<void> _showCreateQuestionDialog() async {
    final controller = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ask a Question'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Your question...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ask'),
          ),
        ],
      ),
    );
    
    if (result == true && controller.text.trim().isNotEmpty) {
      try {
        final appState = Provider.of<AppState>(context, listen: false);
        await appState.apiService.createQuestion(controller.text.trim());
        _loadQuestions();
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
      return const LoadingIndicator(message: 'Loading questions...');
    }
    
    if (_error != null) {
      return ErrorDisplay(message: _error!, onRetry: _loadQuestions);
    }
    
    return Scaffold(
      body: _questions == null || _questions!.isEmpty
          ? const Center(child: Text('No questions yet'))
          : RefreshIndicator(
              onRefresh: _loadQuestions,
              child: ListView.builder(
                itemCount: _questions!.length,
                itemBuilder: (context, index) {
                  final question = _questions![index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(question['text'] ?? ''),
                      subtitle: Text('${question['replies'] ?? 0} replies'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuestionDetailScreen(
                              questionId: question['id'],
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
            onPressed: _showCreateQuestionDialog,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}
