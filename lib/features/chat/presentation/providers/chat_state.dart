import 'package:blood_donation/features/chat/data/models/chat_message_model.dart';

enum ChatStatus { initial, loading, sending, success, error }

class ChatState {
  final ChatStatus status;
  final List<ChatMessageModel> messages;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessageModel>? messages,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == ChatStatus.loading;
  bool get isSending => status == ChatStatus.sending;
  bool get isError => status == ChatStatus.error;
  bool get hasMessages => messages.isNotEmpty;
}