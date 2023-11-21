import 'package:blackbox/features/home/HomeApp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  TextEditingController captionController = TextEditingController();

  Future<void> savePost(String userId, String userName, String text) async {
    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': userId,
        'userName': userName,
        'text': text,
        'likes': 0,
        'timestamp': FieldValue.serverTimestamp(), 
      });
      print('Post added successfully');
      // Navigate back to the previous screen or perform any desired action
     
    } catch (e) {
      print('Error adding post: $e');
    }
  }

  Future<String> getFullName(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userSnapshot.get('full_name') ?? 'Unknown';
    } catch (e) {
      print('Error getting full name: $e');
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: captionController,
            decoration: InputDecoration(
              labelText: 'Caption',
              border: OutlineInputBorder(),
            ),
            maxLines: null, // Allow multiple lines for the caption
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // Get the currently signed-in user
              User? user = FirebaseAuth.instance.currentUser;

              if (user != null) {
                String userId = user.uid;

                // Get the full name from Firestore
                String userName = await getFullName(userId);

                String text = captionController.text;

                if (text.isNotEmpty) {
                  savePost(userId, userName, text);
                   Get.to(HomeApp());
                } else {
                  // Show an error message or handle empty caption
                  print('Caption is empty');
                }
              } else {
                // User is not signed in. Handle this case if needed.
                print('User is not signed in');
              }
            },
            child: Text('Post'),
          ),
        ],
      ),
    );
  }
}
