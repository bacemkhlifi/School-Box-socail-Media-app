class Post {
  final String userId;
  final String userName;
  final String text;
  final List<String> likes;

  Post({
    required this.userId,
    required this.userName,
    required this.text,
    required this.likes,
  });
}
