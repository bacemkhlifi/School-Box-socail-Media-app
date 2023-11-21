import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_model.dart';

class ChatService {
  final CollectionReference chatsCollection = FirebaseFirestore.instance.collection('chats');

  Future<List<Chat>> getChats(String userId) async {
    // Fetch chats where the current user is the participant
    // You may need to structure your data to fetch the chats where userId is either userId or recipientId
    QuerySnapshot<Object?> snapshot =
        await chatsCollection.where('userId', isEqualTo: userId).get();

    List<Chat> chats = snapshot.docs.map((doc) {
      return Chat(
        id: doc.id,
        userId: doc['userId'],
        recipientId: doc['recipientId'],
        lastMessage: doc['lastMessage'],
        timestamp: (doc['timestamp'] as Timestamp).toDate(),
      );
    }).toList();

    return chats;
  }

  Future<void> startChat(String userId, String recipientId, String message) async {
    // Create a new chat document
    await chatsCollection.add({
      'userId': userId,
      'recipientId': recipientId,
      'lastMessage': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
