class Chat {
  final String id;
  final String userId; // ID of the user who initiated the chat
  final String recipientId;
  final String senderId; // ID of the user you're chatting with
  final String lastMessage;
  final DateTime timestamp;

  Chat({
    required this.id,
    required this.userId,
    required this.recipientId,
    required this.senderId,
    required this.lastMessage,
    required this.timestamp,
  });
}
