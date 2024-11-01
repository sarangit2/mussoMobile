class ChatMessage {
  final String content;
  final String sender;
  final DateTime timestamp;

  ChatMessage({required this.content, required this.sender})
      : timestamp = DateTime.now();

  // Convertit un message en JSON pour l'envoi
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
