import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
 
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  late User _user;
  late Map<String, dynamic> _userData = {};
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _loadUserData();
    
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(_user.uid).get();

    setState(() {
      _userData = userSnapshot.data() as Map<String, dynamic>;
      _bioController.text = _userData['bio'] ?? '';
    });
  }

  Future<void> _updateBio(String newBio) async {
    await _firestore.collection('users').doc(_user.uid).update({
      'bio': newBio,
    });
    _loadUserData();
  }
  
Future<void> _updateProfilePicture() async {
  final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    try {
      // Upload the image to Firebase Storage
      String imagePath = 'profile_pictures/${_user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      UploadTask uploadTask = FirebaseStorage.instance.ref().child(imagePath).putFile(File(pickedFile.path));

      // Use FutureBuilder to listen for completion and handle UI accordingly
      await uploadTask.whenComplete(() async {
        // Get the download URL of the uploaded image
        String downloadURL = await FirebaseStorage.instance.ref(imagePath).getDownloadURL();

        // Update the user's Firestore document with the image URL
        await _firestore.collection('users').doc(_user.uid).update({
          'profile_picture': downloadURL,
        });

        // Reload user data to reflect the changes
        _loadUserData();
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
             GestureDetector(
      onTap: () async {
      // Call the method to update the profile picture
      await _updateProfilePicture();
    
      // Reload user data to reflect changes
      _loadUserData();
      },
      child: CircleAvatar(
      radius: 40,
      // Use the user's profile picture from the loaded data
      backgroundImage: _userData['profile_picture'] != null
          ? NetworkImage(_userData!['profile_picture'] as String)
          : const AssetImage('assets/profile.jpg') as ImageProvider<Object>,
      ),
    ),
    
    
    
    
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData['full_name'] ?? 'Your Full Name',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              _userData['posts']?.toString() ?? '0',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Posts'),
                          ],
                        ),
                        SizedBox(width: 16),
                        Column(
                          children: [
                            Text(
                              _userData['followers']?.toString() ?? '0',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Followers'),
                          ],
                        ),
                        SizedBox(width: 16),
                        Column(
                          children: [
                            Text(
                              _userData['following']?.toString() ?? '0',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Following'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              
              ],
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _userData['bio'] ?? 'Bio or description here',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditBioBottomSheet(context);
                  },
                ),
            ],
          ),
          SizedBox(height: 36),
          // Add a grid of user's publications (photos) here
          // You can use GridView.builder to display a dynamic grid of images
          // Replace the placeholder 'buildPublication' function with your implementation
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Adjust the number of columns as needed
            ),
            itemCount: 9, // Replace with the actual number of user's publications
            itemBuilder: (context, index) {
              return buildPublication(index);
            },
          ),
        ],
      ),
    );
  }



  Widget buildPublication(int index) {
    // Placeholder function for building a publication widget
    return Container(
      color: Colors.grey, // Replace with the actual image or data
      margin: EdgeInsets.all(4),
    );
  }

  void _showEditBioBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _bioController,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    labelText: 'Edit Bio',
                    hintText: 'Enter your bio (max 30 characters)',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _updateBio(_bioController.text);
                  Navigator.pop(context);
                },
                child:const Text('Update'),
              ),
            ],
          ),
        );
      },
    );
  }
}
