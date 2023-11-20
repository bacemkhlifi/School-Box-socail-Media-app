import 'package:flutter/material.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  TextEditingController captionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Padding(
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
              onPressed: () {
                // Implement logic to save the post
                // You can use captionController.text to get the caption
                // After saving, navigate to the home screen or perform any desired action
              },
              child: Text('Post'),
            ),
          ],
        ),
    
    );
  }
}
