import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<DocumentSnapshot> posts = snapshot.data!.docs;

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return buildPostCard(posts[index]);
                },
              ),
            ),
          ],
        );
      },
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
   final String _currentuserid = FirebaseAuth.instance.currentUser!.uid ;
   

  return Card(
    margin: EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(''), // Replace with the owner's profile picture URL
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
}


}
