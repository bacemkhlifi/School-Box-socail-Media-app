import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivitiesScreen extends StatelessWidget {
  final String currentUserId; // Pass the current user's ID to the screen

  ActivitiesScreen({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activities'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('userId', isEqualTo: currentUserId) // Filter by the current user's posts
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              DocumentSnapshot post = posts[index];
              return ActivityTile(
                postUserId: currentUserId,
                postId: post.id,
              );
            },
          );
        },
      ),
    );
  }
}

class ActivityTile extends StatelessWidget {
  final String postUserId;
  final String postId;

  ActivityTile({required this.postUserId, required this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: getLikesUserIds(postId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          //return const CircularProgressIndicator();
        }

        List<String> likesUserIds = snapshot.data ?? [];

        return Column(
  children: likesUserIds
      .map((likeUserId) => FutureBuilder<UserProfile>(
            future: getUserProfile(likeUserId),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                // return CircularProgressIndicator();
              }

              UserProfile userProfile = userSnapshot.data ?? UserProfile(userName: 'Unknown', profilePicture: '');

              return FutureBuilder<String>(
                future: getFirstWordFromPost(postId),
                builder: (context, postSnapshot) {
                  if (postSnapshot.connectionState == ConnectionState.waiting) {
                    // return CircularProgressIndicator();
                  }

                  String firstWord = postSnapshot.data ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: userProfile.profilePicture.isNotEmpty
                          ? NetworkImage(userProfile.profilePicture)
                          : const AssetImage('assets/default_profile.jpg') as ImageProvider<Object>,
                    ),
                    title: Text('${userProfile.userName} liked your post: "$firstWord..."'),
                  );
                },
              );
            },
          ))
      .toList(),
);


      },
    );
  }

  Future<List<String>> getLikesUserIds(String postId) async {
    try {
      DocumentSnapshot postSnapshot =
          await FirebaseFirestore.instance.collection('posts').doc(postId).get();

      List<dynamic> likes = postSnapshot['likes'] ?? [];
      return likes.cast<String>().toList();
    } catch (e) {
      print('Error getting likes: $e');
      return [];
    }
  }

  Future<String> getUserNameById(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();

      return userSnapshot.get('full_name') ?? 'Unknown';
    } catch (e) {
      print('Error getting user name: $e');
      return 'Unknown';
    }
  }

   Future<UserProfile> getUserProfile(String userId) async {
    try {
      // Replace 'users' with the actual collection name where user information is stored
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        // Access the 'full_name' and 'profile_picture' fields in the user document
        String userName = userSnapshot.data()?['full_name'] ?? '';
        String profilePicture = userSnapshot.data()?['profile_picture'] ?? '';

        return UserProfile(userName: userName, profilePicture: profilePicture);
      } else {
        // Handle the case where the user document does not exist
        print('User document does not exist for userId: $userId');
        return UserProfile(userName: '', profilePicture: '');
      }
    } catch (e) {
      // Handle any errors that might occur during the Firestore operation
      print('Error during getUserProfile operation: $e');
      return UserProfile(userName: '', profilePicture: '');
    }
  }

  Future<String> getFirstWordFromPost(String postId) async {
    try {
      DocumentSnapshot postSnapshot =
          await FirebaseFirestore.instance.collection('posts').doc(postId).get();

      String text = postSnapshot.get('text') ?? '';
      // Splitting the text into words and taking the first word
      List<String> words = text.split(' ');
      return words.isNotEmpty ? words.first : '';
    } catch (e) {
      print('Error getting first word from post: $e');
      return '';
    }
  }
}
class UserProfile {
  final String userName;
  final String profilePicture;

  UserProfile({required this.userName, required this.profilePicture});
}