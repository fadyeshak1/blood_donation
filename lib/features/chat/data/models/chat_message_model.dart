enum MessageType { text, quickReply, info }

class ChatMessageModel {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;

  const ChatMessageModel({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      message: json['message'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
    };
  }

  // Quick reply suggestions
  static List<String> getQuickReplies() {
    return [
      'When can I donate again?',
      'Find donation centers',
      'Donation requirements',
      'Check my history',
      'Blood type compatibility',
    ];
  }

  // Bot responses based on user input
  static String getBotResponse(String userMessage) {
    final msg = userMessage.toLowerCase();

    if (msg.contains('donate again') || msg.contains('when can')) {
      return 'You can donate blood every 56 days (8 weeks). If you donated platelets, you can donate again after 7 days. Make sure you\'re feeling healthy and well-rested! 💉';
    } else if (msg.contains('donation center') ||
        msg.contains('find') ||
        msg.contains('near')) {
      return 'Here are donation centers near you:\n\n📍 Cairo University Hospital - Giza\n📍 Ain Shams Hospital - Nasr City\n📍 Kasr Al Ainy Hospital - Downtown\n\nWould you like directions to any of these?';
    } else if (msg.contains('requirement') ||
        msg.contains('eligible') ||
        msg.contains('can i donate')) {
      return 'To donate blood, you must:\n\n✓ Be 18-65 years old\n✓ Weigh at least 50 kg\n✓ Be in good health\n✓ Not have donated in the last 8 weeks\n✓ Have valid ID\n\nWould you like to schedule a donation?';
    } else if (msg.contains('history') || msg.contains('my donation')) {
      return 'Your donation history:\n\n🩸 Last donation: 45 days ago\n🩸 Total donations: 12\n🩸 Lives saved: 36\n🩸 Next eligible: 11 days\n\nYou\'re doing amazing! Keep it up! 🌟';
    } else if (msg.contains('blood type') ||
        msg.contains('compatibility') ||
        msg.contains('compatible')) {
      return 'Blood Type Compatibility:\n\n🅰️ A+ can donate to: A+, AB+\n🅱️ B+ can donate to: B+, AB+\n🆎 AB+ can donate to: AB+ (Universal recipient)\n🅾️ O+ can donate to: A+, B+, AB+, O+\n🅾️ O- can donate to: Everyone (Universal donor)\n\nWhat\'s your blood type?';
    } else if (msg.contains('hello') ||
        msg.contains('hi') ||
        msg.contains('hey')) {
      return 'Hello! 👋 I\'m here to help you with blood donation. How can I assist you today?';
    } else if (msg.contains('thank')) {
      return 'You\'re welcome! Happy to help. Is there anything else you\'d like to know? 😊';
    } else {
      return 'I can help you with:\n\n• Donation eligibility\n• Finding donation centers\n• Checking your history\n• Blood type info\n• Scheduling donations\n\nWhat would you like to know?';
    }
  }

  // Welcome message
  static ChatMessageModel getWelcomeMessage() {
    return ChatMessageModel(
      id: 'welcome',
      message:
          'Hi! 👋 I\'m your Blood Donation Assistant. I can help you with:\n\n• Finding donation centers\n• Checking eligibility\n• Understanding blood types\n• Viewing your history\n\nHow can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
  }
}