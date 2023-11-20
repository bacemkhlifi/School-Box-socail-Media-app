
import 'package:blackbox/screens/login.dart';
import 'package:blackbox/screens/signUp.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: 'AIzaSyDtjXXCwoHVbhRRVyKxCcXQv_2X1GoD6aM',
            appId: '1:444440830371:android:0e0cdecbb48b44d3d47a16',
            messagingSenderId: '444440830371',
            projectId: 'shcool-box'));
    print('Firebase initialization successful');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}
