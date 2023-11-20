// lib/features/profile/profile_screen.dart

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                // Replace with user's profile picture
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Full Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            '10', // Replace with actual number of posts
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Posts'),
                        ],
                      ),
                      SizedBox(width: 16),
                      Column(
                        children: [
                          Text(
                            '100', // Replace with actual number of followers
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Followers'),
                        ],
                      ),
                      SizedBox(width: 16),
                      Column(
                        children: [
                          Text(
                            '50', // Replace with actual number of following
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Following'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Bio or description here', // Replace with the user's bio
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 36),
        // Add a grid of user's publications (photos) here
        // You can use GridView.builder to display a dynamic grid of images
        // Replace the placeholder 'buildPublication' function with your implementation
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Adjust the number of columns as needed
          ),
          itemCount: 9, // Replace with the actual number of user's publications
          itemBuilder: (context, index) {
            return buildPublication(index);
          },
        ),
      ],
    );
  }

  Widget buildPublication(int index) {
    // Placeholder function for building a publication widget
    return Container(
      color: Colors.grey, // Replace with the actual image or data
      margin: EdgeInsets.all(4),
    );
  }
}
