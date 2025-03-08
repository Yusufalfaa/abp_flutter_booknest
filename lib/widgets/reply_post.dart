import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReplyPost extends StatelessWidget {
  final String username;
  final String date;
  final String content;

  const ReplyPost({
    required this.username,
    required this.date,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(_formatDate(date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(content),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy', 'en_US').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }
}
