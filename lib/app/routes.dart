// lib/app/routes.dart

import 'package:get/get_navigation/src/routes/get_route.dart';

import '../features/home/HomeApp.dart';
import '../screens/profile.dart';
import '../screens/search.dart';

class AppRoutes {
  static final String home = '/';
  static final String search = '/search';
  static final String profile = '/profile';

  static final routes = [
    
    GetPage(name: search, page: () =>  SearchScreen()),
    GetPage(name: profile, page: () => ProfileScreen()),
  ];
}
