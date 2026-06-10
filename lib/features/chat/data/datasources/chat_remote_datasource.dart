import 'dart:convert';
import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/features/chat/data/models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<ChatMessageModel> sendMessage(String message, String language);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;

  const ChatRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ChatMessageModel> sendMessage(
      String message, String language) async {
    final response = await apiClient.post(
      '/api/chatbot/message',
      body: {
        'message': message,
        'language': language,
      },
    );

    if (response.statusCode == 200) {
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ChatMessageModel.fromResponse(json);
    }

    throw Exception(ApiClient.errorMessage(response));
  }
}