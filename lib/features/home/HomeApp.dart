// lib/features/home/home_screen.dart

import 'package:blackbox/screens/profile.dart';
import 'package:blackbox/screens/search.dart';
import 'package:flutter/material.dart';

import '../../screens/addPosteScreen.dart';
import 'homeScreen.dart';


class HomeApp extends StatefulWidget {
  @override
  State<HomeApp> createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  int _currentIndex = 0; // Store the current index
 
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
            icon:const Icon(Icons.person),
            onPressed: () {
              // Handle the action when the person icon is pressed
            },
          ),
        ],
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
 
  