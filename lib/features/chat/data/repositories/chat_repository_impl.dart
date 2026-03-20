
import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:blood_donation/features/chat/data/models/chat_message_model.dart';

abstract class ChatRepository {
  Future<ApiResult<ChatMessageModel>> sendMessage(String message);
  Future<ApiResult<List<ChatMessageModel>>> getChatHistory(String userId);
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  const ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<ChatMessageModel>> sendMessage(String message) async {
    try {
      final response = await remoteDataSource.sendMessage(message);
      return ApiSuccess(response);
    } catch (e) {
      return ApiFailure('Failed to send message: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<List<ChatMessageModel>>> getChatHistory(
    String userId,
  ) async {
    try {
      final history = await remoteDataSource.getChatHistory(userId);
      return ApiSuccess(history);
    } catch (e) {
      return ApiFailure('Failed to load chat history: ${e.toString()}');
    }
  }
}