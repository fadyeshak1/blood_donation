import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/chat/data/models/chat_message_model.dart';
import 'package:blood_donation/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:flutter/foundation.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository repository;

  final List<ChatMessageModel> _messages = [
    ChatMessageModel.welcome(),
  ];

  bool _isSending = false;
  String _detectedLanguage = 'ar'; // default

  ChatProvider(this.repository);

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;

  /// Detects language from the message text (simple heuristic).
  String _detectLanguage(String text) {
    // Arabic unicode range
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text) ? 'ar' : 'en';
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    final trimmed = text.trim();
    _detectedLanguage = _detectLanguage(trimmed);

    // Add user message
    _messages.add(ChatMessageModel.user(trimmed));

    // Add loading bubble
    _messages.add(ChatMessageModel.loading());
    _isSending = true;
    notifyListeners();

    // Call API
    final result =
        await repository.sendMessage(trimmed, _detectedLanguage);

    // Remove loading bubble
    _messages.removeWhere((m) => m.isLoading);
    _isSending = false;

    switch (result) {
      case ApiSuccess(data: final reply):
        _messages.add(reply);
      case ApiFailure(message: final error):
        _messages.add(ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: 'عذراً، حدث خطأ. يرجى المحاولة مرة أخرى.\n\n$error',
          isUser: false,
          timestamp: DateTime.now(),
        ));
    }

    notifyListeners();
  }

  void clearChat() {
    _messages
      ..clear()
      ..add(ChatMessageModel.welcome());
    notifyListeners();
  }
}