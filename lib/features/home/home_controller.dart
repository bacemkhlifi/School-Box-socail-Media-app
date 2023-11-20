
import 'package:get/get.dart';

import '../../data/models/post_model.dart';

class HomeController extends GetxController {
  RxList<Post> posts = <Post>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize the posts with sample data
    posts.assignAll([
          // Add more posts as needed
    ]);
  }
}


