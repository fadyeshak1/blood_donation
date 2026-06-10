class ChatMessageModel {
  final String id;
  final String message;   // field name matches existing codebase
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;
  final List<String> recommendations;
  final bool? isEligible;
  final int? waitDays;

  const ChatMessageModel({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
    this.recommendations = const [],
    this.isEligible,
    this.waitDays,
  });

  factory ChatMessageModel.user(String text) => ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: text,
        isUser: true,
        timestamp: DateTime.now(),
      );

  factory ChatMessageModel.loading() => ChatMessageModel(
        id: 'loading',
        message: '',
        isUser: false,
        timestamp: DateTime.now(),
        isLoading: true,
      );

  factory ChatMessageModel.fromResponse(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: json['reply'] as String? ?? '',
      isUser: false,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isEligible: json['isEligible'] as bool?,
      waitDays: (json['waitDays'] as num?)?.toInt(),
    );
  }

  factory ChatMessageModel.welcome() => ChatMessageModel(
        id: 'welcome',
        message: 'Hi! 👋 I\'m your Blood Donation Assistant. I can help you with:\n\n'
            '• Understanding blood types\n'
            '• ايه هي اجراءات التبرع بالدم\n\n'
            'How can I help you today?\n\n'
            '---\n'
            'مرحباً! يمكنني أيضاً مساعدتك باللغة العربية 🇸🇦',
        isUser: false,
        timestamp: DateTime.now(),
      );
}