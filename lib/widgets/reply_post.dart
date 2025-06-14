import 'package:booknest/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        String? avatar;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data.containsKey('avatar')) {
            avatar = data['avatar'];
          }
        }

        ImageProvider avatarImage;
        if (avatar == null || avatar.isEmpty) {
          avatarImage = const AssetImage('assets/25.png');
        } else if (avatar.startsWith('/assets/')) {
          avatarImage = AssetImage(avatar.substring(1));
        } else if (avatar.startsWith('http')) {
          avatarImage = NetworkImage(avatar);
        } else {
          avatarImage = const AssetImage('assets/25.png');
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: avatarImage,
                      radius: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(_formatDate(date),
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      color: lightColor,
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteDialog(context);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'delete',
                          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                          height: 30,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 100),
                            child: Align(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
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
                const SizedBox(height: 8),
                Text(content),
              ],
            ),
          ),
        );
      },
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

  void _showDeleteDialog(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid != userId) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can't delete this reply")));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
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
                await CommunityService().deleteReply(postId, replyId);
                onDelete();
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Reply deleted successfully")));
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
