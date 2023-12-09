// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../features/home/favorites/favoriteController.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  late String userId;
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final FavoriteController favoriteController = Get.put(FavoriteController());
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
        await _firestore.collection('users').doc(widget.userId).get();

    setState(() {
      _userData = userSnapshot.data() as Map<String, dynamic>;
      _bioController.text = _userData['bio'] ?? '';
    });
  }

  Future<void> _updateBio(String newBio) async {
    await _firestore.collection('users').doc(widget.userId).update({
      'bio': newBio,
    });
    _loadUserData();
  }

  Future<void> _updateProfilePicture() async {
    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        // Upload the image to Firebase Storage
        String imagePath =
            'profile_pictures/${widget.userId}/${DateTime.now().millisecondsSinceEpoch}.jpg';

        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child(imagePath)
            .putFile(File(pickedFile.path));

        // Use FutureBuilder to listen for completion and handle UI accordingly
        await uploadTask.whenComplete(() async {
          // Get the download URL of the uploaded image
          String downloadURL =
              await FirebaseStorage.instance.ref(imagePath).getDownloadURL();

          // Update the user's Firestore document with the image URL
          await _firestore.collection('users').doc(widget.userId).update({
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
    return Scaffold(
      appBar: _user.uid != widget.userId ? AppBar() : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _user.uid == widget.userId
                        ? GestureDetector(
                            onTap: () async {
                              // Call the method to update the profile picture
                              await _updateProfilePicture();

                              // Reload user data to reflect changes
                              _loadUserData();
                            },
                            child: CircleAvatar(
                              radius: 40,
                              // Use the user's profile picture from the loaded data
                              backgroundImage: _userData['profile_picture'] !=
                                      null
                                  ? NetworkImage(
                                      _userData!['profile_picture'] as String)
                                  : const AssetImage('assets/profile.jpg')
                                      as ImageProvider<Object>,
                            ),
                          )
                        : CircleAvatar(
                            radius: 40,
                            // Use the user's profile picture from the loaded data
                            backgroundImage:
                                _userData['profile_picture'] != null
                                    ? NetworkImage(
                                        _userData!['profile_picture'] as String)
                                    : const AssetImage('assets/profile.jpg')
                                        as ImageProvider<Object>,
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
                                  _userData['email']?.toString() ?? '',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                //Text('Posts'),
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
                  ),
                  _user.uid == widget.userId
                      ? IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditBioBottomSheet(context);
                          },
                        )
                      : Container(),
                ],
              ),
              SizedBox(height: 36),
              // Add a grid of user's publications (photos) here
              // You can use GridView.builder to display a dynamic grid of images
              // Replace the placeholder 'buildPublication' function with your implementation
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('posts')
                    .where('userId', isEqualTo: widget.userId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  List<DocumentSnapshot> posts = snapshot.data!.docs;
                  return posts.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final reversedIndex = posts.length - 1 - index;
                            return buildPublication(
                                widget.userId, posts[reversedIndex]);
                          },
                          // Check if there are no posts
                        )
                      : const Center(
                          child: Text('No posts yet.'),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPublication(String userId, DocumentSnapshot post) {
    String text = post.get('text') ?? '';
    String ownerId = post.get('userName') ?? '';
    String uid = post.get('userId') ?? '';
    String imageUrl = post.get('imageUrl') ?? '';

    Timestamp timestamp = post.get('timestamp') ?? Timestamp.now();
    DateTime dateTime = timestamp.toDate();
    String formattedTime =
        ' ${dateTime.day}/${dateTime.month}/${dateTime.year}';

    final String _currentuserid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<String>(
      future: getProfileUrl(uid),
      builder: (context, snapshot) {
        String profileUrl = snapshot.data ?? '';

        return Card(
          margin: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 40,
                  backgroundImage: profileUrl.isNotEmpty
                      ? NetworkImage(profileUrl)
                      : const AssetImage('assets/profile.jpg')
                          as ImageProvider<Object>,
                ),
                title: GestureDetector(
                  child: Text('$ownerId'),
                  onTap: () {
                    Get.to(ProfileScreen(userId: uid));
                  },
                ),
                subtitle: Text(
                  DateFormat('hh:mm a').format(dateTime).toString() +
                      formattedTime,
                ),
                trailing: _currentuserid == uid
                    ? IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('posts')
                              .doc(post.id)
                              .delete();
                        },
                      )
                    : null,
              ),
              if (imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      // Show bottom sheet with full-size image

                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: 450.0,
                      ),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text,
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        favoriteController.toggleFavorite(
                            post.id, _currentuserid);
                      },
                      child: Obx(
                        () => Icon(
                          favoriteController.isFavorite(post.id, _currentuserid)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FutureBuilder<int>(
                      // Fetch like count from the database
                      future: getLikeCountFromDatabase(post.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          int likeCount = snapshot.data ?? 0;

                          return GestureDetector(
                            child: Text('$likeCount Likes'),
                            onTap: () async {
                              List<String> userIds = await favoriteController
                                  .getLikesList(post.id);
                              showLikeListBottomSheet(context, userIds);
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
                child: const Text('Update'),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<int> getLikeCountFromDatabase(String postId) async {
  try {
    // Replace 'posts' with the actual collection name where posts are stored
    DocumentSnapshot<Map<String, dynamic>> postSnapshot =
        await FirebaseFirestore.instance.collection('posts').doc(postId).get();

    if (postSnapshot.exists) {
      // Access the 'likes' field in the post document
      return postSnapshot.data()?['likes'].length ?? 0;
    } else {
      // Handle the case where the post document does not exist
      print('Post document does not exist for postId: $postId');
      return 0; // You can return a default value or handle this case differently
    }
  } catch (e) {
    // Handle any errors that might occur during the Firestore operation
    print('Error during getLikeCountFromDatabase operation: $e');
    return 0; // You can return a default value or handle this case differently
  }
}

Future<String> getProfileUrl(String uid) async {
  try {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userSnapshot.exists) {
      return userSnapshot.get('profile_picture') ??
          ''; // Replace with your field name for the profile URL
    } else {
      // User with the given UID not found
      return ''; // or throw an exception, handle it based on your app's logic
    }
  } catch (e) {
    print('Error getting profile URL: $e');
    return ''; // or throw an exception, handle it based on your app's logic
  }
}

class LikeListBottomSheet extends StatelessWidget {
  final List<String> userIds;

  LikeListBottomSheet({required this.userIds});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Users who liked the post:'),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            itemCount: userIds.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: FutureBuilder<String>(
                  future: getUserName(userIds[index]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Loading...');
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text(snapshot.data ?? 'Unknown');
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<String> getUserName(String userId) async {
    // Implement logic to fetch the user's name from the database
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userSnapshot.get('full_name') ?? 'Unknown';
  }
}

void showLikeListBottomSheet(BuildContext context, List<String> userIds) {
  showModalBottomSheet(
    context: context,
    builder: (context) => LikeListBottomSheet(userIds: userIds),
  );
}
