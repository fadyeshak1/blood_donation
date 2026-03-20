import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/chat/data/models/chat_message_model.dart';
import 'package:blood_donation/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:blood_donation/features/chat/presentation/providers/chat_state.dart';
import 'package:flutter/foundation.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository repository;
  ChatState _state = const ChatState();

  ChatProvider(this.repository);

  ChatState get state => _state;

  void _setState(ChatState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadChatHistory(String userId) async {
    _setState(_state.copyWith(status: ChatStatus.loading));

    final result = await repository.getChatHistory(userId);

    switch (result) {
      case ApiSuccess(data: final historyData):
        _setState(_state.copyWith(
          status: ChatStatus.success,
          messages: historyData,
        ));
      case ApiFailure(message: final errorMsg):
        _setState(_state.copyWith(
          status: ChatStatus.error,
          errorMessage: errorMsg,
        ));
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message immediately
    final userMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _setState(_state.copyWith(
      messages: [..._state.messages, userMessage],
      status: ChatStatus.sending,
    ));

    // Get bot response
    final result = await repository.sendMessage(message);

    switch (result) {
      case ApiSuccess(data: final botMessage):
        _setState(_state.copyWith(
          status: ChatStatus.success,
          messages: [..._state.messages, botMessage],
        ));
      case ApiFailure(message: final errorMsg):
        _setState(_state.copyWith(
          status: ChatStatus.error,
          errorMessage: errorMsg,
        ));
    }
  }
}