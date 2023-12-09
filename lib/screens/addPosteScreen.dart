import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../features/home/HomeApp.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  TextEditingController captionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? pickedImage;
  User? user = FirebaseAuth.instance.currentUser;
  bool isPosting = false; // Add a flag to track if posting is in progress

  Future<void> savePost(
      String userId, String userName, String text, String? imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': userId,
        'userName': userName,
        'text': text,
        'imageUrl': imageUrl, // Add imageUrl to store image link
        'likes': [], // Initialize likes as an empty list
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Post added successfully');
    } catch (e) {
      print('Error adding post: $e');
    }
  }

  Future<String> getFullName(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userSnapshot.get('full_name') ?? 'Unknown';
    } catch (e) {
      print('Error getting full name: $e');
      return 'Unknown';
    }
  }

  Future<void> _uploadImage() async {
    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        pickedImage = pickedFile;
      });
    }
  }

  Future<void> _post() async {
    // Check if posting is already in progress
    if (isPosting) {
      return;
    }

    setState(() {
      isPosting = true; // Set the flag to indicate posting is in progress
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;
        String userName = await getFullName(userId);
        String text = captionController.text;
        if (pickedImage != null) {
          // Upload the image to Firebase Storage
          String imagePath =
              'post_images/${DateTime.now().millisecondsSinceEpoch}.jpg';

          UploadTask uploadTask = FirebaseStorage.instance
              .ref()
              .child(imagePath)
              .putFile(File(pickedImage!.path));

          // Wait for the image upload to complete
          await uploadTask.whenComplete(() async {
            // Get the download URL of the uploaded image
            String downloadURL =
                await FirebaseStorage.instance.ref(imagePath).getDownloadURL();

            // Get the currently signed-in user
            await savePost(userId, userName, text, downloadURL);
            Get.to(HomeApp());
          });
        } else {
          // Handle case when no image is selected
          print('No image selected');
           await savePost(userId, userName, text, '');
        }
        // Save the post with the image URL
       
      } else {
        // User is not signed in. Handle this case if needed.
        print('User is not signed in');
      }
    } catch (e) {
      print('Error uploading image and saving post: $e');
    } finally {
      setState(() {
        isPosting =
            false; // Reset the flag after posting is complete or an error occurs
      });
      Get.to(HomeApp()); // Navigate back to home screen after posting
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview
            GestureDetector(
              onTap: _uploadImage,
              child: pickedImage != null
                  ? Container(
                      constraints: BoxConstraints(
                          maxHeight: 350.0), // Set your desired max height
                      child: Image.file(
                        File(pickedImage!.path),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      height: 150,
                      color: Colors.grey, // Placeholder color
                      child: Center(
                        child: Text(
                          'Tap to pick image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 16),
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
              onPressed: isPosting
                  ? null
                  : _post, // Disable the button if posting is in progress
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
