import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class ChatMessageData {
  final String role;
  final String content;
  ChatMessageData({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
  };
}

/// A service that connects to the Healix Backend RAG Chatbot.
class ChatService {
  static const String _baseUrl = 'https://healix-rgwin.onrender.com/api/v1';
  static const String _tag = 'ChatService';
  static final http.Client _client = http.Client();

  static const String greeting = 'Hello! I am the Healix AI Assistant. I can answer questions about our products, ingredients, and company. How can I help you?';

  static Future<String> getReply(List<ChatMessageData> history) async {
    try {
      developer.log('📡 [API] POST $_baseUrl/chat/', name: _tag);
      
      final response = await _client.post(
        Uri.parse('$_baseUrl/chat/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'messages': history.map((m) => m.toJson()).toList(),
        }),
      ).timeout(const Duration(seconds: 45));

      developer.log('📥 [API] Chat status: ${response.statusCode}', name: _tag);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['reply'] ?? 'Sorry, I received an empty response.';
      } else {
        developer.log('❌ [API] Chat error ${response.body}', name: _tag);
        return 'I am currently experiencing technical difficulties connecting to the server. Please try again later.';
      }
    } catch (e, stack) {
      developer.log('💥 [API] Chat exception: $e', name: _tag, error: e, stackTrace: stack);
      return 'I cannot reach the server right now. Please check your internet connection.';
    }
  }
}
