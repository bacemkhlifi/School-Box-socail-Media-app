import 'package:blackbox/data/models/post_model.dart';
import 'package:blackbox/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'favorites/favoriteController.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _refreshPosts() async {
    // Implement logic to refresh posts, e.g., fetch data from Firestore
    // You can also call setState() to rebuild the UI with the updated data
    // For now, I'm just delaying for demonstration purposes
    await Future.delayed(Duration(seconds: 2));
  }

  final FavoriteController favoriteController = Get.put(FavoriteController());

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshPosts,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot> posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return buildPostCard(posts[index]);
            },
          );
        },
      ),
    );
  }

  Widget buildPostCard(DocumentSnapshot post) {
    String text = post.get('text') ?? '';
    String ownerId = post.get('userName') ?? '';
    String uid = post.get('userId') ?? '';
    String imageUrl = post.get('imageUrl') ??
        ''; // Assuming 'imageUrl' is the field storing post image URL

    Timestamp timestamp = post.get('timestamp') ?? Timestamp.now();

    DateTime dateTime = timestamp.toDate();
    String formattedTime =
        ' ${dateTime.day}/${dateTime.month}/${dateTime.year}';

    // Get the current user's ID (replace this with your actual method of getting the user ID)
    final String _currentuserid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<String>(
      future: getProfileUrl(uid),
      builder: (context, snapshot) {
        String profileUrl =
            snapshot.data ?? ''; // Use an empty string if profileUrl is null

        return Card(
          margin: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 40,
                  // Use the user's profile picture from the loaded data
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
                ), // Replace with the owner's name
                subtitle: Text(
                  DateFormat('hh:mm a').format(dateTime).toString() +
                      formattedTime,
                ),
                trailing: _currentuserid == uid
                    ? IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Implement logic to delete the post from Firestore
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
                    child: Container(
                      constraints: BoxConstraints(
                          maxHeight: 450.0), // Set your desired max height
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 200, // Set height as per your requirement
                        fit: BoxFit.cover,
                      ),
                    )),
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
                        // Handle like button tap (toggle color, update like count, etc.)
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
                    SizedBox(width: 8),
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
                    // Replace with actual like count
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<int> getLikeCountFromDatabase(String postId) async {
    try {
      // Replace 'posts' with the actual collection name where posts are stored
      DocumentSnapshot<Map<String, dynamic>> postSnapshot =
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .get();

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
