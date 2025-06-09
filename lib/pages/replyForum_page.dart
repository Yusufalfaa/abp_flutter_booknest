import 'package:booknest/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booknest/services/community.dart';
import 'package:booknest/widgets/reply_post.dart';
import 'package:booknest/models/forum.dart';
import 'package:booknest/models/reply.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _replyController.addListener(() {
      int charCount = _replyController.text.length;
      if (charCount <= _maxLength) {
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
    if (_replyController.text
        .trim()
        .isNotEmpty && _charCount <= _maxLength) {
      setState(() {
        _isLoading = true;
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

      await CommunityService().addReplyToPost(widget.originalPost.id, reply);

      _fetchUpdatedForumPost();

      setState(() {
        _isLoading = false;
        _replyController.clear();
        _charCount = 0;
      });
    }
  }

  Future<void> _fetchUpdatedForumPost() async {
    try {
      Forum updatedPost = await CommunityService().getForumPostById(
          widget.originalPost.id);
      setState(() {
        widget.originalPost.replies = updatedPost.replies;
      });
    } catch (e) {
      print('Error fetching updated forum post: $e');
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
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.originalPost.userId)
                  .get(),
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
                            CircleAvatar(
                              backgroundImage: avatarImage,
                              radius: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.originalPost.username ??
                                        'Unknown User',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    DateFormat('dd MMMM yyyy')
                                        .format(
                                        widget.originalPost.date.toDate()),
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.originalPost.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.originalPost.content ?? 'No content available',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),
            const Divider(thickness: 0.5, color: Colors.grey),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.chat_bubble_outline,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${widget.originalPost.replies} Replies',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder<List<Reply>>(
                stream: CommunityService()
                    .getRepliesForPost(widget.originalPost.id),
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
                        date: DateFormat('yyyy-MM-dd').format(reply.dateTime),
                        content: reply.content,
                        replyId: reply.id,
                        postId: widget.originalPost.id,
                        userId: reply.userId,
                        onDelete: _fetchUpdatedForumPost,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}