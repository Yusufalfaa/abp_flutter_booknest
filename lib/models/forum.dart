import 'package:cloud_firestore/cloud_firestore.dart';

class Forum {
  String id;
  String userId;
  String username;
  String title;
  String content;
  int replies;
  Timestamp date;

  Forum({
    required this.id,
    required this.userId,
    required this.username,
    required this.title,
    required this.content,
    required this.replies,
    required this.date,
  });

  factory Forum.fromMap(Map<String, dynamic> map) {
    return Forum(
      id: map['id'],
      userId: map['userId'],
      username: map['username'],
      title: map['title'],
      content: map['content'],
      replies: map['replies'] ?? 0,
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'title': title,
      'content': content,
      'replies': replies,
      'date': date,
    };
  }

  DateTime get dateTime => date.toDate();
}
