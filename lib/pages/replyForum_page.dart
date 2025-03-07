import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:booknest/models/forum.dart';
import 'package:booknest/models/reply.dart';
import 'package:booknest/services/community.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReplyForumPage extends StatefulWidget {
  final Forum originalPost; // Accept Forum object instead of Map

  const ReplyForumPage({super.key, required this.originalPost});

  @override
  _ReplyForumPageState createState() => _ReplyForumPageState();
}

class _ReplyForumPageState extends State<ReplyForumPage> {
  final TextEditingController _replyController = TextEditingController();
  int _charCount = 0; // Character count for max limit
  final int _maxLength = 2500; // Maximum character limit

  @override
  void initState() {
    super.initState();
    _replyController.addListener(() {
      setState(() {
        _charCount = _replyController.text.length;
        if (_charCount > _maxLength) {
          _replyController.text = _replyController.text.substring(0, _maxLength);
          _replyController.selection = TextSelection.fromPosition(
            TextPosition(offset: _replyController.text.length),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  // Method to submit a new reply
  void _submitReply() async {
    if (_replyController.text.trim().isNotEmpty && _charCount <= _maxLength) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Handle the case where the user is not logged in
        return;
      }

      // Create a reply object with current timestamp
      Reply reply = Reply(
        userId: user.uid,
        username: user.displayName ?? 'Anonymous',
        content: _replyController.text.trim(),
        date: Timestamp.now(), // Use Firestore Timestamp here
      );

      // Add the reply to the forum post
      await CommunityService().addReplyToPost(widget.originalPost.id, reply);

      setState(() {
        _replyController.clear();
        _charCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the original forum post
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.zero,
              color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                              Text(
                                widget.originalPost.username ?? 'Unknown User',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                softWrap: true,
                              ),
                              Text(
                                widget.originalPost.date.toDate().toString().substring(0, 10),
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.originalPost.content ?? 'No content available',
                      style: const TextStyle(fontSize: 14),
                      softWrap: true,
                    ),
                    const SizedBox(height: 16),
                    // TextField for replying
                    TextField(
                      controller: _replyController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Write your reply here...',
                        hintStyle: const TextStyle(fontSize: 14),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        counterText: '',
                      ),
                      maxLength: _maxLength,
                    ),
                    const SizedBox(height: 8),
                    // Reply button and counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$_charCount/$_maxLength',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _submitReply,
                          child: const Text('Post'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
