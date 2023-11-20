// lib/features/home/home_screen.dart

import 'package:blackbox/screens/profile.dart';
import 'package:blackbox/screens/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../screens/addPosteScreen.dart';
import '../../screens/login.dart';
import 'homeScreen.dart';


class HomeApp extends StatefulWidget {
  @override
  State<HomeApp> createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  int _currentIndex = 0; // Store the current index
   final FirebaseAuth _auth = FirebaseAuth.instance;


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User _user;
  late Map<String, dynamic>  _userData = {};

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
    });
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      print('Logout successful');

      // Navigate to the login screen
      Get.offAll(LoginScreen());
    } catch (e) {
      // Handle logout errors
      print('Logout Error: $e');
      // You can show an error message to the user if needed
    }
  }
 
final List<Widget> _screens = [
    HomeScreen(), 
    SearchScreen(),
    AddPostScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const  Text('SchoolBox'),
        actions: [
          IconButton(
            icon:const Icon(Icons.favorite_border),
            onPressed: () {
              // Handle the action when the person icon is pressed
            },
          ),
          IconButton(
            icon:const Icon(Icons.chat),
            onPressed: () {
              // Handle the action when the person icon is pressed
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_userData['full_name'] ?? 'username'), // Replace with user's name
              accountEmail: Text(_userData['email'] ?? 'user@schoolbox.com'), // Replace with user's email
              currentAccountPicture: CircleAvatar(
                // You can load the user's profile picture here
                backgroundImage: AssetImage('assets/profile_picture.jpg'),
              ),
            ),
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.logout),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body:  IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
     bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor:Colors.purple,
        selectedItemColor:Colors.black,
        unselectedItemColor:Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'New Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
 
  