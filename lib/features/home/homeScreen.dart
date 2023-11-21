import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshPosts,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
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
    Timestamp timestamp = post.get('timestamp') ?? Timestamp.now();

    DateTime dateTime = timestamp.toDate();
    String formattedTime = '${dateTime.hour}:${dateTime.minute}, ${dateTime.day}/${dateTime.month}/${dateTime.year}';

    // Get the current user's ID (replace this with your actual method of getting the user ID)
    final String _currentuserid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<String>(
      future: getProfileUrl(uid),
      builder: (context, snapshot) {
        String profileUrl = snapshot.data ?? ''; // Use an empty string if profileUrl is null

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
                      : const AssetImage('assets/profile.jpg') as ImageProvider<Object>,
                ),
                title: Text('$ownerId'), // Replace with the owner's name
                subtitle: Text(formattedTime),
                trailing: _currentuserid == uid
                    ? IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Implement logic to delete the post from Firestore
                          FirebaseFirestore.instance.collection('posts').doc(post.id).delete();
                        },
                      )
                    : null,
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
                        // Handle like button tap (toggle color, update like count, etc.)
                      },
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red, // Change color based on like status
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('0 Likes'), // Replace with actual like count
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> getProfileUrl(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        return userSnapshot.get('profile_picture') ?? ''; // Replace with your field name for the profile URL
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
