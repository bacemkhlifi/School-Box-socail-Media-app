import 'package:flutter/material.dart';

class ChatDetailsScreen extends StatelessWidget {
  final String userId;
  final String selectedUser;
  final String name;

  ChatDetailsScreen({required this.userId, required this.selectedUser, required this.name});

  @override
  Widget build(BuildContext context) {
    // Implement the chat details screen where you can send a message to the selected user
    return Scaffold(
      appBar: AppBar(
        title: Text('$name'),
      ),
      body: Center(
        child: Text('Send a message to $name.'),
      ),
    );
  }
}