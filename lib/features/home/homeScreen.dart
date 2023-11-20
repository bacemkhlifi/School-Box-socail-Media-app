import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});
 final HomeController controller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Expanded(
          child: Obx(
            () => ListView.builder(
              itemCount: controller.posts.length,
              itemBuilder: (context, index) {
                return buildPostCard(controller.posts[index]);
              },
            ),
          ),
        ),
      ],
    );
  }
  

  Widget buildPostCard(Post post) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            title: Text(post.userName),
          ),
          Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 300.0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              post.caption,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }


}