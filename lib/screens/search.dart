import 'package:blackbox/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<QueryDocumentSnapshot> userList = [];
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _searchController = TextEditingController();

  Future<void> fetchUserList(String query) async {
    try {
      if (query.isEmpty) {
        setState(() {
          userList = [];
        });
        return;
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('full_name', isGreaterThanOrEqualTo: query)
          .get();

      setState(() {
        userList = querySnapshot.docs
            .where((user) => user.id != _currentUserId)
            .toList();
      });
    } catch (e) {
      print('Error fetching user list: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      fetchUserList(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              return buildSearchResult(userList[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget buildSearchResult(QueryDocumentSnapshot user) {
    return ListTile(
      leading: CircleAvatar(
        // Replace with user's profile picture
        backgroundImage: NetworkImage(user['profile_picture']),
      ),
      title: Text(user['full_name']),
      subtitle: Text(user['bio']),
      onTap: () {
         Get.to(ProfileScreen(userId: user.id));
      },
    );
  }
}
