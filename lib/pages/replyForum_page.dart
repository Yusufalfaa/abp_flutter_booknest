import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:booknest/models/forum.dart';
import 'package:booknest/models/reply.dart';
import 'package:booknest/services/community.dart';
import 'package:booknest/widgets/reply_post.dart';
import 'package:booknest/pages/home_page.dart';

const double buttonRadius = 8.0;

class ReplyForumPage extends StatefulWidget {
  final Forum originalPost;

  const ReplyForumPage({super.key, required this.originalPost});

  @override
  _ReplyForumPageState createState() => _ReplyForumPageState();
}

class _ReplyForumPageState extends State<ReplyForumPage> {
  final TextEditingController _replyController = TextEditingController();
  int _charCount = 0;
  final int _maxLength = 2500;
  bool _isLoading = false; // Flag untuk status loading

  @override
  void initState() {
    super.initState();
    _replyController.addListener(() {
      // Update character count without rebuilding the entire widget
      int charCount = _replyController.text.length;
      if (charCount <= _maxLength) {
        // Only update the char count, no need to rebuild the entire widget
        _charCount = charCount;
      }
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submitReply() async {
    if (_replyController.text.trim().isNotEmpty && _charCount <= _maxLength) {
      setState(() {
        _isLoading = true; // Set loading to true when posting reply
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      Reply reply = Reply(
        id: '',
        userId: user.uid,
        username: user.displayName ?? 'Anonymous',
        content: _replyController.text.trim(),
        date: Timestamp.now(),
      );

      // Tambahkan reply ke post
      await CommunityService().addReplyToPost(widget.originalPost.id, reply);

      setState(() {
        widget.originalPost.replies += 1; // Increment reply count
        _isLoading = false; // Stop loading after reply is posted
        _replyController.clear(); // Clear the text field
        _charCount = 0; // Reset character count
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightColor,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original Post Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.originalPost.username ?? 'Unknown User',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              // Format tanggal post sesuai dengan format yang diinginkan (yyyy-MM-dd)
                              Text(
                                DateFormat('dd MMMM yyyy').format(widget.originalPost.date.toDate()),
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.originalPost.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.originalPost.content ?? 'No content available',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Textarea if user is logged in
            if (user != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextField(
                  controller: _replyController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Write your reply here...',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    counterText: '',
                  ),
                  maxLength: _maxLength,
                ),
              ),

              // Post Button
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$_charCount/$_maxLength',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: _submitReply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(buttonRadius),
                          ),
                        ),
                        child: const Text('Post'),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Divider
            const SizedBox(height: 12),
            const Divider(thickness: 0.5, color: Colors.grey),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${widget.originalPost.replies} Replies',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Stack(
                children: [
                  StreamBuilder<List<Reply>>(
                    stream: CommunityService().getRepliesForPost(widget.originalPost.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("Reply not available"));
                      }
                      final replies = snapshot.data!;
                      return ListView.builder(
                        itemCount: replies.length,
                        itemBuilder: (context, index) {
                          final reply = replies[index];
                          return ReplyPost(
                            username: reply.username,
                            date: DateFormat('yyyy-MM-dd').format(reply.dateTime), // format tanggal
                            content: reply.content,
                          );
                        },
                      );
                    },
                  ),
                  // Loading Indicator (Brown Color)
                  if (_isLoading)
                    Container(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.brown, // Set the color of the loading spinner
                        ),
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
}
