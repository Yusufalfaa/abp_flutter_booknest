import 'package:flutter/material.dart';
import 'home_page.dart';
import 'newForum_page.dart';
import 'replyForum_page.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  bool isPopularTabActive = true; // State untuk melacak tab aktif

  // Data statis sebagai contoh/dump content dengan format tanggal "yyyy-MM-dd", replies, dan avatarPath
  final List<Map<String, String>> samplePosts = [
    {
      'username': 'YoungAdultFan',
      'date': '2024-12-06',
      'title': 'Captivating YA Novels',
      'content': 'What’s a young adult novel that absolutely captivated you?',
      'replies': '4',
      'avatarPath': 'assets/avt (1).jpg', // Path avatar untuk YoungAdultFan
    },
    {
      'username': 'FantasyAdventurer',
      'date': '2024-12-04',
      'title': 'Epic Fantasy Series Recommendations',
      'content': 'I’m looking for a new epic fantasy series to dive into. Something like "The Stormlight Archive."',
      'replies': '3',
      'avatarPath': 'assets/avt (2).jpg', // Path avatar untuk FantasyAdventurer
    },
    {
      'username': 'Alexander G',
      'date': '2024-10-16',
      'title': 'Themes in 1984',
      'content': 'Do you think aspects of our modern society mirror the themes of surveillance and thought control depicted in Orwell’s 1984?',
      'replies': '2',
      'avatarPath': 'assets/avt (5).jpg', // Path avatar untuk Alexander
    },
    {
      'username': 'YoungAdultFan',
      'date': '2024-10-13',
      'title': 'Orwell’s 1984 Analysis',
      'content': 'How does Orwell’s 1984 explore the impact of a totalitarian regime on truth and individuality?',
      'replies': '1',
      'avatarPath': 'assets/avt (1).jpg', // Path avatar untuk YoungAdultFan (sama karena username sama)
    },
    {
      'username': 'Alexander D',
      'date': '2024-10-14',
      'title': 'Surveillance in Modern Society',
      'content': 'Are there parallels between Orwell’s 1984 and today’s surveillance practices?',
      'replies': '3',
      'avatarPath': 'assets/avt (4).jpg', // Path avatar untuk Alexander
    },
    {
      'username': 'FantasyAdventurer',
      'date': '2024-10-13',
      'title': 'Thought Control in 1984',
      'content': 'What are your thoughts on the theme of thought control in Orwell’s 1984?',
      'replies': '5',
      'avatarPath': 'assets/avt (2).jpg', // Path avatar untuk FantasyAdventurer
    },
    {
      'username': 'Alexander G',
      'date': '2024-10-12',
      'title': '1984 Discussion',
      'content': 'How does Orwell’s 1984 reflect on the dangers of a totalitarian regime?',
      'replies': '4',
      'avatarPath': 'assets/avt (5).jpg', // Path avatar untuk Alexander
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> displayedPosts = isPopularTabActive
        ? (List<Map<String, String>>.from(samplePosts)
      ..sort((a, b) => int.parse(b['replies'] ?? '0').compareTo(int.parse(a['replies'] ?? '0'))))
        : (List<Map<String, String>>.from(samplePosts)
      ..sort((a, b) => DateTime.parse(b['date'] ?? '1970-01-01').compareTo(DateTime.parse(a['date'] ?? '1970-01-01'))));

    return Scaffold(
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
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
                        "Sharing, find support, and connect with community",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
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
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(buttonRadius),
                      color: Colors.grey[300],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isPopularTabActive = true;
                              });
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
                              child: Text(
                                'Popular',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
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
                              });
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
                              child: Text(
                                'Latest',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: displayedPosts.length,
                    itemBuilder: (context, index) {
                      final post = displayedPosts[index];
                      final replies = int.tryParse(post['replies'] ?? '0') ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: ForumPost(
                          username: post['username'] ?? 'Unknown User',
                          date: post['date'] ?? 'Unknown Date',
                          title: post['title'] ?? 'Untitled',
                          content: post['content'] ?? 'No content available',
                          replies: replies,
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
                          avatarPath: post['avatarPath'] ?? 'assets/profiles/default_avatar.jpg', // Default avatar jika tidak ada
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Definisikan ForumPost di dalam file yang sama
class ForumPost extends StatelessWidget {
  final String username;
  final String date;
  final String title;
  final String content;
  final int replies;
  final VoidCallback onReplyTap;
  final String avatarPath; // Parameter baru untuk path avatar

  const ForumPost({
    required this.username,
    required this.date,
    required this.title,
    required this.content,
    required this.replies,
    required this.onReplyTap,
    required this.avatarPath, // Tambahkan parameter ini
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonRadius),
      ),
      margin: EdgeInsets.zero,
      color: lightColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(avatarPath),
                        radius: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              softWrap: true,
                            ),
                            Text(
                              date,
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    softWrap: true,
                  ),
                  SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(fontSize: 14),
                    softWrap: true,
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: onReplyTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '$replies Reply(s)',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                            softWrap: true,
                          ),
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
}