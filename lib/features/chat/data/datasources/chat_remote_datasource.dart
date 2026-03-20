import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/features/chat/data/models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<ChatMessageModel> sendMessage(String message);
  Future<List<ChatMessageModel>> getChatHistory(String userId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;

  const ChatRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ChatMessageModel> sendMessage(String message) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // TODO: Replace with actual AI API call
    /*
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/chat/message'),
      headers: await apiClient.getHeaders(),
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      return ChatMessageModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to send message');
    */

    // Generate bot response
    final botResponse = ChatMessageModel.getBotResponse(message);

    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: botResponse,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
  }

  @override
  Future<List<ChatMessageModel>> getChatHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: Replace with actual API call
    /*
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/chat/$userId/history'),
      headers: await apiClient.getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ChatMessageModel.fromJson(json)).toList();
    }

    throw Exception('Failed to load chat history');
    */

    // Return welcome message for now
    return [ChatMessageModel.getWelcomeMessage()];
  }
}