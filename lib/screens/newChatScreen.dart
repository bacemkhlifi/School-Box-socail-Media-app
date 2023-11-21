import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/services/chat_service.dart';
import 'chatDetails.dart';

class NewChatScreen extends StatefulWidget {
  final String userId; // Current user's ID

  NewChatScreen({required this.userId});

  @override
  _NewChatScreenState createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final ChatService chatService = ChatService();
  List<QueryDocumentSnapshot> userList = [];

  @override
  void initState() {
    super.initState();
    // Fetch the list of users when the screen is initialized
    fetchUserList();
  }

  Future<void> fetchUserList() async {
    try {
      // Implement logic to fetch the list of users from Firestore
      // Example: userList = await chatService.fetchUserList();
      // Replace 'users' with your actual Firestore collection name

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
       userList = querySnapshot.docs
          .where((user) => user.id != widget.userId) // Filter out the current user
          .toList();
      });
    } catch (e) {
      print('Error fetching user list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start a New Chat'),
      ),
      body: userList.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final user = userList[index].data() as Map<String, dynamic>;
                final String selectedUserId = userList[index].id; // Extract UID

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['profile_picture'] ?? ''), // Replace with your field name for the profile picture URL
                  ),
                  title: Text(user['full_name'] ?? 'Unknown'), // Replace with your field name for the full name
                  onTap: () {
                    // Navigate to the chat details screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailsScreen(
                          userId: widget.userId,
                          selectedUser: selectedUserId,
                          name:user['full_name'] 
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
