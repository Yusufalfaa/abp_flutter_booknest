import 'package:flutter/material.dart';
import 'home_page.dart';

class ReplyForumPage extends StatefulWidget {
  final Map<String, String> originalPost;

  const ReplyForumPage({super.key, required this.originalPost});

  @override
  _ReplyForumPageState createState() => _ReplyForumPageState();
}

class _ReplyForumPageState extends State<ReplyForumPage> {
  final TextEditingController _replyController = TextEditingController();
  List<Map<String, String>> replies = [
    {
      'username': 'FantasyExplorer',
      'date': '2024-12-04',
      'content': 'For an epic fantasy, try The First Law Trilogy by Joe Abercrombie—it’s dark and captivating.',
      'avatarPath': 'assets/avt (3).jpg',
    },
    {
      'username': 'FantasyExplorer',
      'date': '2024-12-04',
      'content': 'For an epic fantasy, try The First Law Trilogy by Joe Abercrombie—it’s dark and captivating.',
      'avatarPath': 'assets/avt (3).jpg',
    },
    {
      'username': 'FantasyExplorer',
      'date': '2024-12-04',
      'content': 'For an epic fantasy, try The First Law Trilogy by Joe Abercrombie—it’s dark and captivating.',
      'avatarPath': 'assets/avt (3).jpg',
    },
    {
      'username': 'FantasyExplorer',
      'date': '2024-12-04',
      'content': 'For an epic fantasy, try The First Law Trilogy by Joe Abercrombie—it’s dark and captivating.',
      'avatarPath': 'assets/avt (3).jpg',
    },
    {
      'username': 'JaneReader',
      'date': '2024-12-25',
      'content': 'That’s a good book',
      'avatarPath': 'assets/avt (2).jpg',
    },
  ]; // Data balasan statis sebagai contoh

  int _charCount = 0; // Menghitung jumlah karakter untuk batas 2500
  final int _maxLength = 2500; // Batas maksimum karakter

  @override
  void initState() {
    super.initState();
    _replyController.addListener(() {
      setState(() {
        _charCount = _replyController.text.length;
        if (_charCount > _maxLength) {
          _replyController.text =
              _replyController.text.substring(0, _maxLength);
          _replyController.selection = TextSelection.fromPosition(
            TextPosition(offset: _replyController.text.length),
          );
        }
      });
    });
    print('Replies initialized: $replies'); // Debugging: Cek apakah data dimuat
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submitReply() {
    if (_replyController.text
        .trim()
        .isNotEmpty && _charCount <= _maxLength) {
      setState(() {
        replies.add({
          'username': 'CurrentUser', // Username statis untuk demo front-end
          'date': DateTime.now().toString().substring(0, 10), // Tanggal lokal
          'content': _replyController.text.trim(),
          'avatarPath': 'assets/avt (3).jpg', // Avatar statis untuk demo
        });
        _replyController.clear();
        _charCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: blackColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Postingan Asli dengan TextField untuk Balasan
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
              ),
              margin: EdgeInsets.zero,
              color: lightColor,
              // Set the card background color to lightColor
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(widget
                              .originalPost['avatarPath'] ??
                              'assets/profiles/default_avatar.jpg'),
                          radius: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.originalPost['username'] ??
                                    'Unknown User',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                                softWrap: true,
                              ),
                              Text(
                                widget.originalPost['date'] ?? 'Unknown Date',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.originalPost['content'] ?? 'No content available',
                      style: const TextStyle(fontSize: 14),
                      softWrap: true,
                    ),
                    const SizedBox(height: 16),
                    // TextField untuk Balasan (Mengikuti gaya NewForumPage)
                    TextField(
                      controller: _replyController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Write your reply here...',
                        hintStyle: const TextStyle(fontSize: 14),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(buttonRadius),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        counterText: '',
                      ),
                      maxLength: _maxLength,
                    ),
                    const SizedBox(height: 8),

                    // Baris untuk counter dan tombol Post
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$_charCount/$_maxLength',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _submitReply,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            minimumSize: const Size(100, 30),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text(
                            'Post',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Replies (${replies.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (replies.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    'No replies yet.', style: TextStyle(color: Colors.grey)),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    final reply = replies[index];
                    print('Rendering reply $index: ${reply['username']}');
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      color: lightColor,
                      // Set the card background color to lightColor
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: AssetImage(
                                            reply['avatarPath'] ??
                                                'assets/profiles/default_avatar.jpg'),
                                        radius: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                              reply['username'] ??
                                                  'Unknown User',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14),
                                              softWrap: true,
                                            ),
                                            Text(
                                              reply['date'] ?? 'Unknown Date',
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    reply['content'] ?? '',
                                    style: const TextStyle(fontSize: 14),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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