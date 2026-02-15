import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_config.dart';

class SocketService {
  IO.Socket? _socket;
  final List<Function(dynamic)> _messageListeners = [];
  final List<Function(dynamic)> _privateMessageListeners = [];
  final List<Function(dynamic)> _historyListeners = [];
  
  void connect(String token) {
    _socket = IO.io(
      AppConfig.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'token': token})
          .enableAutoConnect()
          .build(),
    );
    
    _socket?.on('connect', (_) {
      print('Socket connected');
    });
    
    _socket?.on('message', (data) {
      for (var listener in _messageListeners) {
        listener(data);
      }
    });
    
    _socket?.on('private_message', (data) {
      for (var listener in _privateMessageListeners) {
        listener(data);
      }
    });
    
    _socket?.on('history', (data) {
      for (var listener in _historyListeners) {
        listener(data);
      }
    });
    
    _socket?.on('error', (error) {
      print('Socket error: $error');
    });
    
    _socket?.on('disconnect', (_) {
      print('Socket disconnected');
    });
  }
  
  void sendMessage(String text) {
    _socket?.emit('message', {'text': text});
  }
  
  void sendPrivateMessage(String chatId, String text) {
    _socket?.emit('private_message', {'chatId': chatId, 'text': text});
  }
  
  void joinPrivateChat(String chatId) {
    _socket?.emit('join_private', {'chatId': chatId});
  }
  
  void leavePrivateChat(String chatId) {
    _socket?.emit('leave_private', {'chatId': chatId});
  }
  
  void onMessage(Function(dynamic) listener) {
    _messageListeners.add(listener);
  }
  
  void onPrivateMessage(Function(dynamic) listener) {
    _privateMessageListeners.add(listener);
  }
  
  void onHistory(Function(dynamic) listener) {
    _historyListeners.add(listener);
  }
  
  void removeMessageListener(Function(dynamic) listener) {
    _messageListeners.remove(listener);
  }
  
  void removePrivateMessageListener(Function(dynamic) listener) {
    _privateMessageListeners.remove(listener);
  }
  
  void removeHistoryListener(Function(dynamic) listener) {
    _historyListeners.remove(listener);
  }
  
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
  
  bool get isConnected => _socket?.connected ?? false;
}
