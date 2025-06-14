import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:booknest/models/forum.dart';
import 'package:booknest/services/community.dart';
import 'package:booknest/widgets/forum_post.dart';
import 'package:booknest/pages/replyForum_page.dart';
import 'package:booknest/pages/newForum_page.dart';
import 'package:booknest/pages/home_page.dart';

const double buttonRadius = 8.0;

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  bool isPopularTabActive = true;
  bool _isLoading = false;
  final CommunityService _communityService = CommunityService();

  List<Forum> _forumPosts = [];
  Map<String, String> _avatarUrls = {};

  @override
  void initState() {
    super.initState();
    _fetchForumPosts(); // langsung panggil load data
  }

  Future<void> _fetchForumPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Forum> posts = await _communityService.getForumPosts(byReplies: isPopularTabActive);

      Set<String> userIds = posts.map((e) => e.userId).toSet();
      Map<String, String> avatarUrls = await _communityService.getAvatarUrlsForUserIds(userIds.toList());

      setState(() {
        _forumPosts = posts;
        _avatarUrls = avatarUrls;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching forums: $e");
    }
  }

  void _deleteForumPost(String postId) async {
    await _communityService.deleteForumPost(postId);
    _fetchForumPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.brown))
          : Column(
        children: [
          // Header + Tabs + Button (tidak berubah)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Let's Talk",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Sharing, find support, and connect with the community",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius)),
                    minimumSize: Size(double.infinity, 50),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () async {
                    User? user = FirebaseAuth.instance.currentUser;

                    if (user == null) {
                      Navigator.pushReplacementNamed(context, '/sign-in');
                    } else {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NewForumPage()),
                      );

                      if (result == true) {
                        _fetchForumPosts();
                      }
                    }
                  },
                  child: const Text("New Discussion",
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                ),
                SizedBox(height: 16),
                // Tabs for Popular / Latest
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(buttonRadius),
                    color: Colors.grey[300],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!isPopularTabActive) {
                                setState(() {
                                  isPopularTabActive = true;
                                });
                                _fetchForumPosts();
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isPopularTabActive ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(buttonRadius),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              alignment: Alignment.center,
                              child: Text('Popular',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: isPopularTabActive ? primaryColor : Colors.black)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (isPopularTabActive) {
                                setState(() {
                                  isPopularTabActive = false;
                                });
                                _fetchForumPosts();
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: !isPopularTabActive ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(buttonRadius),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              alignment: Alignment.center,
                              child: Text('Latest',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: !isPopularTabActive ? primaryColor : Colors.black)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),

          // List forum posts with avatar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: _forumPosts.length,
                itemBuilder: (context, index) {
                  final post = _forumPosts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: ForumPost(
                      username: post.username,
                      avatarUrl: _avatarUrls[post.userId] ?? "",
                      date: post.date.toDate().toString(),
                      title: post.title,
                      content: post.content,
                      replies: post.replies,
                      userId: post.userId,
                      onReplyTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReplyForumPage(originalPost: post),
                          ),
                        ).then((_) {
                          _fetchForumPosts();
                        });
                      },
                      onDeleteTap: post.userId == FirebaseAuth.instance.currentUser?.uid
                          ? () {
                        _deleteForumPost(post.id);
                      }
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
