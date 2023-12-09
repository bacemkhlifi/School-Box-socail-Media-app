import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_model.dart';

class ChatService {
  final CollectionReference chatsCollection =
      FirebaseFirestore.instance.collection('chats');
  // A Stream to listen for changes in the chat list
  Future<List<String>> getChatIds(String userId) async {
    List<String> chatIds = [];

    try {
      QuerySnapshot<Object?> data = await chatsCollection.get();

      // Process 'chats' data as needed
      data.docs.forEach((doc) {
        if (doc.id.contains(userId)) {
          chatIds.add(doc.id);
        }
      });
    } catch (e) {
      print('Error during get operation: $e');
    }

    return chatIds;
  }

  final StreamController<List<Chat>> _chatStreamController =
      StreamController<List<Chat>>.broadcast();

  Stream<List<Chat>> get chatStream => _chatStreamController.stream;

  Future<List<Chat>> getChatsStream(String userId) async {
    List<Chat> chats = [];

    List<String> chatIds = await getChats(userId);
    for (String chatId in chatIds) {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(chatId)
              .get();

      if (docSnapshot.exists) {
        // Convert the data to a Map<String, dynamic>
        Map<String, dynamic>? data = docSnapshot.data();

        // Access the 'lastMessage' field in the specified path
        var lastMessageData = data?['lastMessage'];
        print('lastMessageData');
        print(lastMessageData);

        // Assuming you have a Chat model, you can create a Chat object with the lastMessageData
        if (lastMessageData != null) {
          Chat chat = Chat(
            recipientId: lastMessageData['recipientId'] ?? '',
            lastMessage: lastMessageData['text'] ?? '',
            timestamp: (lastMessageData['timestamp'] as Timestamp).toDate(),
            id: chatId,
            userId: userId,
            senderId: lastMessageData['senderId'] ?? '',
          );

          chats.add(chat);
        }
      } else {
        print('Document does not exist for chatId: $chatId');
      }
    }

    // Sort the chats based on the timestamp in descending order
    chats.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return chats;
  }

  Future<List<String>> getChats(String currentUserId) async {
    List<String> chatIds = [];

    try {
      QuerySnapshot<Map<String, dynamic>> data =
          await FirebaseFirestore.instance.collection('chats').get();
      print("Number of documents in 'chats':${data.size} ");

      // Process 'chats' data as needed
      data.docs.forEach((doc) {
        if (doc.id.contains(currentUserId)) {
          chatIds.add(doc.id);
        }
      });
    } catch (e) {
      print('Error during get operation: $e');
    }

    print("chatIds");
    print(chatIds);
    return chatIds;
  }

  // Close the stream controller when it's no longer needed
  void dispose() {
    _chatStreamController.close();
  }

  
}
