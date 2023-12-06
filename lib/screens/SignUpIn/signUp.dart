import 'package:blackbox/features/home/HomeApp.dart';
import 'package:blackbox/features/home/homeScreen.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'login.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController(); // New controller for full name

  Future<void> _signUp() async {
    try {
      // Set isLoading to true when starting signup
      setState(() {
        isLoading = true;
      });

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Store additional user information in Firestore, including full name
      await _storeUserData(userCredential.user);

      print('Signup successful');

      // Navigate to the home screen
      Get.off(HomeApp());
    } catch (e) {
      // Handle signup errors
      print('Signup Error: $e');
      
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Signup Error'),
            content: Text('$e'.split("]")[1]),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      // Set isLoading to false regardless of success or failure
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _storeUserData(User? user) async {
    if (user != null) {
      // Add user data to Firestore, including full name
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'full_name': _fullNameController.text, // Use entered full name
        'posts': 0,
        'followers': 0,
        'following': 0,
        'bio': 'Bio or description here',
        'profile_picture': '',
        // Add more user data as needed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
      ),
      body: !isLoading ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _fullNameController, // New TextField for full name
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to the login screen
                Get.to(LoginScreen());
              },
              child: Text('Do you have an account? Login'),
            ),
          ],
        ),
      ) : Center(child: CircularProgressIndicator()),
    );
  }
}
