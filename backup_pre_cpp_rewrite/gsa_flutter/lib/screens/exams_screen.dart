import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/common_widgets.dart';
import 'exam_detail_screen.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});
  
  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  List<dynamic>? _exams;
  bool _isLoading = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadExams();
  }
  
  Future<void> _loadExams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final exams = await appState.apiService.getExams();
      if (mounted) {
        setState(() {
          _exams = exams;
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
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Loading exams...');
    }
    
    if (_error != null) {
      return ErrorDisplay(message: _error!, onRetry: _loadExams);
    }
    
    return RefreshIndicator(
      onRefresh: _loadExams,
      child: _exams == null || _exams!.isEmpty
          ? const Center(child: Text('No exams available'))
          : ListView.builder(
              itemCount: _exams!.length,
              itemBuilder: (context, index) {
                final exam = _exams![index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.quiz, size: 40),
                    title: Text(exam['title'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Grade: ${exam['grade'] ?? 'N/A'}'),
                        Text('Questions: ${exam['questionCount'] ?? 0}'),
                      ],
                    ),
                    trailing: Consumer<AppState>(
                      builder: (context, appState, child) {
                        if (!appState.verified) {
                          return const Icon(Icons.lock);
                        }
                        return const Icon(Icons.chevron_right);
                      },
                    ),
                    onTap: () {
                      final appState = Provider.of<AppState>(context, listen: false);
                      if (!appState.verified) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You must be verified to take exams'),
                          ),
                        );
                        return;
                      }
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExamDetailScreen(examId: exam['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
