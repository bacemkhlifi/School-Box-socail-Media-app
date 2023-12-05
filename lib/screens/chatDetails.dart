import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDetailsScreen extends StatefulWidget {
  final String userId;
  final String selectedUser;
  final String name;

  ChatDetailsScreen({
    required this.userId,
    required this.selectedUser,
    required this.name,
  });

  @override
  _ChatDetailsScreenState createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage(String message) {
    String chatId = _generateChatId(widget.userId, widget.selectedUser);

    _firestore.collection('chats/$chatId/messages').add({
      'senderId': widget.userId,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  String _generateChatId(String userId1, String userId2) {
    List<String> sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.name}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats/${_generateChatId(widget.userId, widget.selectedUser)}/messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(
                    child: Text('No messages yet.'),
                  );
                }

                List<QueryDocumentSnapshot> messages = snapshot.data?.docs ?? [];


                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: message['senderId'] == widget.userId ? Text(message['text'],textAlign: TextAlign.end,):Text(message['text']),
                      subtitle:message['senderId'] == widget.userId ? Text(
                        // Format the timestamp as needed
                        '${(message['timestamp']! as Timestamp).toDate()}',textAlign: TextAlign.end,):Text(
                        // Format the timestamp as needed
                        '${(message['timestamp'] as Timestamp).toDate()}')
                   
                    
                    
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
