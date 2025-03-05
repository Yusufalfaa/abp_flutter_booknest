// Model Forum
class Forum {
  final String username;
  final String date;
  final String title;
  final String content;
  final int replies;
  final String avatarPath;

  Forum({
    required this.username,
    required this.date,
    required this.title,
    required this.content,
    required this.replies,
    required this.avatarPath,
  });

  // Convert User object to a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'date': date,
      'title': title,
      'content': content,
      'replies': replies,
      'avatarPath': avatarPath,
    };
  }

  // Create User object from Firestore document
  factory Forum.fromMap(Map<String, dynamic> map) {
    return Forum(
      username: map['username'],
      date: map['date'],
      title: map['title'],
      content: map['content'],
      replies: map['replies'],
      avatarPath: map['avatarPath'],
    );
  }

}