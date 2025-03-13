import 'package:booknest/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForumPost extends StatelessWidget {
  final String username;
  final String date;
  final String title;
  final String content;
  final int replies;
  final String userId;
  final VoidCallback onReplyTap;
  final VoidCallback? onDeleteTap;

  const ForumPost({
    required this.username,
    required this.date,
    required this.title,
    required this.content,
    required this.replies,
    required this.userId,
    required this.onReplyTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    // Format date into "07 March 2025"
    String formattedDate = _formatDate(date);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.zero,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row to align username, date, and the delete icon (three-dot)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Transform.translate(
                            offset: Offset(0, -4),
                            child: Text(
                              formattedDate,
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        ],
                      ),

                      if (onDeleteTap != null && userId == FirebaseAuth.instance.currentUser?.uid)
                      // PopupMenuButton to display 3 dots menu with delete option
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, size: 20),
                          color: lightColor,
                          onSelected: (value) {
                            if (value == 'delete') {
                              _showDeleteDialog(context);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'delete',
                              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                              height: 30,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 100,
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.delete, color: Colors.red, size: 18),
                                      SizedBox(width: 8),
                                      Text("Delete", style: TextStyle(color: Colors.red, fontSize: 14)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    content,
                    style: TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: onReplyTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '$replies Replies',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to format the date to "07 March 2025"
  String _formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy', 'en_US').format(dateTime);
    } catch (e) {
      print('Error formatting date: $e');
      return dateString;
    }
  }

  // Function to show the Delete confirmation dialog
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: lightColor,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          title: const Text("Confirm Delete"),
          content: const Text(
            "Are you sure you want to delete this post?",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                onDeleteTap?.call();
                Navigator.pop(dialogContext);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
