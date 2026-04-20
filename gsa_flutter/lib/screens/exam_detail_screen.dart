import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/common_widgets.dart';

class ExamDetailScreen extends StatefulWidget {
  final String examId;
  
  const ExamDetailScreen({super.key, required this.examId});
  
  @override
  State<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> {
  Map<String, dynamic>? _exam;
  bool _isLoading = false;
  String? _error;
  final Map<String, String> _answers = {};
  Map<String, dynamic>? _results;
  
  @override
  void initState() {
    super.initState();
    _loadExam();
  }
  
  Future<void> _loadExam() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final exam = await appState.apiService.getExam(widget.examId);
      if (mounted) {
        setState(() {
          _exam = exam;
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
  
  Future<void> _submitExam() async {
    if (_answers.length != (_exam!['questions'] as List).length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final results = await appState.apiService.submitExam(widget.examId, _answers);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting exam: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exam')),
        body: const LoadingIndicator(message: 'Loading exam...'),
      );
    }
    
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exam')),
        body: ErrorDisplay(message: _error!, onRetry: _loadExam),
      );
    }
    
    if (_exam == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exam')),
        body: const Center(child: Text('Exam not found')),
      );
    }
    
    if (_results != null) {
      return _buildResultsView();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_exam!['title'] ?? 'Exam'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _exam!['title'] ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Grade: ${_exam!['grade'] ?? 'N/A'}'),
                  Text('Questions: ${(_exam!['questions'] as List).length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...(_exam!['questions'] as List).asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return _buildQuestionCard(index + 1, question);
          }),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitExam,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Submit Exam'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuestionCard(int number, Map<String, dynamic> question) {
    final questionId = question['id'];
    final options = question['options'] as List;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question $number',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(question['text'] ?? ''),
            const SizedBox(height: 16),
            ...options.asMap().entries.map((entry) {
              final option = entry.value;
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _answers[questionId],
                onChanged: (value) {
                  setState(() {
                    _answers[questionId] = value!;
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResultsView() {
    final score = _results!['score'];
    final correct = _results!['correct'];
    final total = _results!['total'];
    
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Results')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '$score%',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: score >= 70 ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You got $correct out of $total correct',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Detailed Results',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...(_results!['results'] as List).asMap().entries.map((entry) {
            final index = entry.key;
            final result = entry.value;
            final isCorrect = result['correct'];
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
                title: Text('Question ${index + 1}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your answer: ${result['userAnswer']}'),
                    if (!isCorrect)
                      Text(
                        'Correct answer: ${result['correctAnswer']}',
                        style: const TextStyle(color: Colors.green),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Exams'),
          ),
        ],
      ),
    );
  }
}
