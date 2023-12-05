import 'package:flutter/material.dart';

import '../data/models/chat_model.dart';
import '../data/services/chat_service.dart';
import 'chatDetails.dart';
import 'newChatScreen.dart';

class ChatScreen extends StatelessWidget {
  final String userId; // Current user's ID
  final ChatService chatService = ChatService();

  ChatScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: FutureBuilder<List<Chat>>(
        future: chatService.getChats(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const  Center(
              child: Text('No chats available. Start a new chat!'),
            );
          } else {
            List<Chat> chats = snapshot.data!;

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${chats[index].recipientId}'),
                  subtitle: Text(chats[index].lastMessage),
                  onTap: () {
                    // Navigate to the chat details screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailsScreen(selectedUser: '', userId: userId,name: userId,),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the screen where you can start a new chat
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewChatScreen(userId: userId),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
  
}
