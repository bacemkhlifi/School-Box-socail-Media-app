
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxList<Post> posts = <Post>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize the posts with sample data
    posts.assignAll([
      Post('John Doe', 'Beautiful sunset! 🌅', 'https://cdn.vox-cdn.com/thumbor/9iDZLE7-TDv1iewdKHOUlbSmXK0=/0x0:5563x3709/920x613/filters:focal(2302x1311:3192x2201):format(webp)/cdn.vox-cdn.com/uploads/chorus_image/image/65752607/1048232144.jpg.0.jpg'),
      Post('Jane Smith', 'Lovely weekend vibes. 😎', 'https://cdn.vox-cdn.com/thumbor/9iDZLE7-TDv1iewdKHOUlbSmXK0=/0x0:5563x3709/920x613/filters:focal(2302x1311:3192x2201):format(webp)/cdn.vox-cdn.com/uploads/chorus_image/image/65752607/1048232144.jpg.0.jpg'),
      // Add more posts as needed
    ]);
  }
}

class Post {
  final String userName;
  final String caption;
  final String imageUrl;

  Post(this.userName, this.caption, this.imageUrl);
}
