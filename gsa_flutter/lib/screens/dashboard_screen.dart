import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'questions_screen.dart';
import 'private_chats_screen.dart';
import 'exams_screen.dart';
import 'global_chat_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = const [
    GlobalChatScreen(),
    QuestionsScreen(),
    PrivateChatsScreen(),
    ExamsScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GSA'),
        actions: [
          Consumer<AppState>(
            builder: (context, appState, child) {
              return Row(
                children: [
                  Text(
                    appState.verified ? 'Verified' : 'Guest',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Switch(
                    value: appState.verified,
                    onChanged: (_) => appState.toggleVerified(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: const Color(0xFF99AAB5),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'Q&A',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Private',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Exams',
          ),
        ],
      ),
    );
  }
}
