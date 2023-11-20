import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        // Add search results or suggestions here
        Expanded(
          child: ListView.builder(
            itemCount: 10, // Replace with the actual number of search results
            itemBuilder: (context, index) {
              return buildSearchResult(index);
            },
          ),
        ),
      ],
    );
  }

  Widget buildSearchResult(int index) {
    // Placeholder function for building a search result widget
    return ListTile(
      leading: CircleAvatar(
        // Replace with user's profile picture
        backgroundImage: AssetImage('assets/profile_picture.jpg'),
      ),
      title: Text('Search Result $index'),
      subtitle: Text('Subtitle or additional information'),
      onTap: () {
        // Handle tapping on a search result
      },
    );
  }
}
