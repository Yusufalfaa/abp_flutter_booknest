import 'package:booknest/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:booknest/services/community.dart';

class ReplyPost extends StatelessWidget {
  final String username;
  final String date;
  final String content;
  final String replyId;
  final String postId;
  final String userId;
  final Function onDelete;

  const ReplyPost({
    required this.username,
    required this.date,
    required this.content,
    required this.replyId,
    required this.postId,
    required this.userId,
    required this.onDelete,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Column for username and date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(_formatDate(date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),

                // PopupMenuButton (three dots) for delete option
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

  // Function to show the Delete confirmation dialog
  void _showDeleteDialog(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid != userId) {
      // If the user is not the one who posted the reply, return
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You can't delete this reply")));
      return;
    }

    // Show delete confirmation dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          title: const Text("Confirm Delete"),
          content: const Text(
            "Are you sure you want to delete this reply?",
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
                // Delete the reply
                await CommunityService().deleteReply(postId, replyId);

                // Call the callback to refresh the reply count
                onDelete();  // Trigger the callback to update reply count

                // Optionally, show success message and dismiss dialog
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Reply deleted successfully")));
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
