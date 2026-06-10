import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:blood_donation/features/chat/data/models/chat_message_model.dart';

abstract class ChatRepository {
  Future<ApiResult<ChatMessageModel>> sendMessage(
      String message, String language);
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource dataSource;

  const ChatRepositoryImpl(this.dataSource);

  @override
  Future<ApiResult<ChatMessageModel>> sendMessage(
      String message, String language) async {
    try {
      final result = await dataSource.sendMessage(message, language);
      return ApiSuccess(result);
    } catch (e) {
      return ApiFailure(
          e.toString().replaceFirst('Exception: ', ''));
    }
  }
}