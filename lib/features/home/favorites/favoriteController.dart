import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class FavoriteController extends GetxController {
  // Map to store liked post IDs and their like counts
  RxMap<String, List<String>> postLikes = RxMap<String, List<String>>();

  bool isFavorite(String postId, String userId) {
    return postLikes[postId]?.contains(userId) ?? false;
  }

  void toggleFavorite(String postId, String userId) {
    List<String> likes = postLikes[postId] ?? [];

    if (isFavorite(postId, userId)) {
      likes.remove(userId);
      // Implement logic to remove like from the database
      removeFromDatabase(postId, userId);
    } else {
      likes.add(userId);
      // Implement logic to add like to the database
      addToDatabase(postId, userId);
    }

    postLikes[postId] = likes;
  }
 Future<List<String>> getLikesList(String postId) async {
    // Implement logic to fetch the list of user IDs who liked the post from the database
    DocumentSnapshot postSnapshot =
        await FirebaseFirestore.instance.collection('posts').doc(postId).get();
    return List<String>.from(postSnapshot.get('likes') ?? []);
  }

  void removeFromDatabase(String postId, String userId) {
    // Implement logic to remove like from the database
    // For example, you might update a list of user IDs in the posts collection
    FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayRemove([userId]),
    });
  }

  void addToDatabase(String postId, String userId) {
    // Implement logic to add like to the database
    // For example, you might update a list of user IDs in the posts collection
    FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayUnion([userId]),
    });
  }

  int likeCount(String postId) {
    return postLikes[postId]?.length ?? 0;
  }
}
