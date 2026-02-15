import 'package:dio/dio.dart';
import '../config/app_config.dart';

class ApiService {
  final Dio _dio;
  String? _token;
  
  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  
  void setToken(String token) {
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  String? get token => _token;
  
  // Auth
  Future<Map<String, dynamic>> anonymousLogin() async {
    final response = await _dio.post('/auth/anonymous');
    final token = response.data['token'];
    if (token != null) {
      setToken(token);
    }
    return response.data;
  }
  
  // Questions
  Future<List<dynamic>> getQuestions() async {
    final response = await _dio.get('/questions');
    return response.data;
  }
  
  Future<Map<String, dynamic>> createQuestion(String text) async {
    final response = await _dio.post('/questions', data: {'text': text});
    return response.data;
  }
  
  Future<Map<String, dynamic>> getQuestion(String id) async {
    final response = await _dio.get('/questions/$id');
    return response.data;
  }
  
  Future<Map<String, dynamic>> replyToQuestion(String id, String text) async {
    final response = await _dio.post('/questions/$id/reply', data: {'text': text});
    return response.data;
  }
  
  // Exams
  Future<List<dynamic>> getExams() async {
    final response = await _dio.get('/exams');
    return response.data;
  }
  
  Future<Map<String, dynamic>> getExam(String id) async {
    final response = await _dio.get('/exams/$id');
    return response.data;
  }
  
  Future<Map<String, dynamic>> submitExam(String id, Map<String, dynamic> answers) async {
    final response = await _dio.post('/exams/$id/submit', data: {'answers': answers});
    return response.data;
  }
  
  // Private Chats
  Future<List<dynamic>> getPrivateChats() async {
    final response = await _dio.get('/private-chats');
    return response.data;
  }
  
  Future<Map<String, dynamic>> createPrivateChat(String name, List<String> members) async {
    final response = await _dio.post('/private-chats', data: {'name': name, 'members': members});
    return response.data;
  }
  
  Future<Map<String, dynamic>> getPrivateChatMessages(String id) async {
    final response = await _dio.get('/private-chats/$id/messages');
    return response.data;
  }
  
  Future<Map<String, dynamic>> joinPrivateChat(String id) async {
    final response = await _dio.post('/private-chats/$id/join');
    return response.data;
  }
}
