import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  String id;
  String userId;
  String username;
  String content;
  Timestamp date;

  Reply({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.date,
  });

  factory Reply.fromMap(Map<String, dynamic> map) {
    return Reply(
      id: map['id'],
      userId: map['userId'],
      username: map['username'],
      content: map['content'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'content': content,
      'date': date,
    };
  }

  DateTime get dateTime => date.toDate();
}
