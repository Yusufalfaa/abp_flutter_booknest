import 'package:flutter/material.dart';
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
  final CommunityService _communityService = CommunityService();
  late Future<List<Forum>> _forumPostsFuture;

  @override
  void initState() {
    super.initState();
    _forumPostsFuture = _communityService.getForumPosts(byReplies: isPopularTabActive);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: FutureBuilder<List<Forum>>(
        future: _forumPostsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<Forum> forumPosts = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // Header with title and description
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Let's Talk",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Sharing, find support, and connect with the community",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // New Discussion Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(buttonRadius),
                          ),
                          minimumSize: Size(double.infinity, 50),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NewForumPage()),
                          );
                        },
                        child: const Text(
                          "New Discussion",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Sorting options (Popular / Latest)
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
                                    setState(() {
                                      isPopularTabActive = true;
                                      _forumPostsFuture =
                                          _communityService.getForumPosts(byReplies: true);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isPopularTabActive
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(buttonRadius),
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Popular',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isPopularTabActive
                                            ? primaryColor
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isPopularTabActive = false;
                                      _forumPostsFuture =
                                          _communityService.getForumPosts(byReplies: false);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: !isPopularTabActive
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(buttonRadius),
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Latest',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: !isPopularTabActive
                                            ? primaryColor
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),

                      // Container with posts or no posts message
                      forumPosts.isEmpty
                          ? Center(child: Text('No posts available.'))
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: forumPosts.length,
                        itemBuilder: (context, index) {
                          final post = forumPosts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: ForumPost(
                              username: post.username,
                              date: post.date.toDate().toString(),
                              title: post.title,
                              content: post.content,
                              replies: post.replies,
                              onReplyTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReplyForumPage(
                                      originalPost: post,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
