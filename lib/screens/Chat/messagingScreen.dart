import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/chat_model.dart';
import '../../data/services/chat_service.dart';
import 'chatDetails.dart';
import 'newChatScreen.dart';

class ChatScreen extends StatefulWidget {
  final String userId;

  ChatScreen({required this.userId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService chatService = ChatService();
  List<QueryDocumentSnapshot> userList = [];

  @override
  void initState() {
    super.initState();
  }

  Future<String> getUserName(String userId) async {
    try {
      // Replace 'users' with the actual collection name where user information is stored
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (userSnapshot.exists) {
        // Access the 'name' field in the user document
        String userName = userSnapshot.data()?['full_name'] ?? '';
        return userName;
      } else {
        // Handle the case where the user document does not exist
        print('User document does not exist for userId: $userId');
        return ''; // You can return a default value or handle this case differently
      }
    } catch (e) {
      // Handle any errors that might occur during the Firestore operation
      print('Error during getUserName operation: $e');
      return ''; // You can return a default value or handle this case differently
    }
  }
late List<Chat> chats;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: RefreshIndicator(
  onRefresh: () async {
    // Fetch the latest chat data
    List<Chat> refreshedChats = await chatService.getChatsStream(widget.userId);

    // Return a Future.delayed to simulate the refreshing process
    return Future.delayed(Duration(seconds: 1), () {
      setState(() {
        // Update the state with the refreshed chats
        chats = refreshedChats;
      });
    });
  },
  child: FutureBuilder<List<Chat>>(
    future: chatService.getChatsStream(widget.userId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: const CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(
          child: Text('No chats available. Start a new chat!'),
        );
      } else {
        List<Chat> chats = snapshot.data!;

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            return FutureBuilder<String>(
              future: getUserName(chats[index].recipientId),
              builder: (context, userNameSnapshot) {
                if (userNameSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return ListTile(
                    title: Text('Loading...'),
                    // You can add more widgets or loading indicators here
                  );
                } else if (userNameSnapshot.hasError) {
                  return ListTile(
                    title: Text('Error: ${userNameSnapshot.error}'),
                  );
                } else {
                  String userName = userNameSnapshot.data ?? '';
                  return ListTile(
                    title: Text(userName),
                    subtitle: Text(
                      chats[index].lastMessage,
                    ),
                    onTap: () {
                      // Navigate to the chat details screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailsScreen(
                            selectedUser: chats[index].recipientId,
                            userId: widget.userId,
                            name: userName,
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            );
          },
        );
      }
    },
  ),
),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the screen where you can start a new chat
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewChatScreen(userId: widget.userId),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
