
import 'package:blackbox/features/home/HomeApp.dart';
import 'package:blackbox/screens/SignUpIn/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'data/services/theme_services.dart';
import 'widgets/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  GetStorage.init();

  try {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: 'AIzaSyDtjXXCwoHVbhRRVyKxCcXQv_2X1GoD6aM',
            appId: '1:444440830371:android:0e0cdecbb48b44d3d47a16',
            messagingSenderId: '444440830371',
            projectId: 'shcool-box',
            storageBucket: "gs://shcool-box.appspot.com",));
    print('Firebase initialization successful');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});
   final FirebaseAuth _auth = FirebaseAuth.instance;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
     theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeServices().theme,
      home:FutureBuilder(
        future: _auth.authStateChanges().first,
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the user is already logged in, go to the home screen
            return snapshot.hasData ? HomeApp() : LoginScreen();
          } else {
            // Show a loading indicator while checking authentication state
            return const  CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
