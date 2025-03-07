import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:booknest/services/community.dart';
import 'package:booknest/models/forum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booknest/pages/home_page.dart';

const double buttonRadius = 8.0;

class NewForumPage extends StatefulWidget {
  const NewForumPage({super.key});

  @override
  _NewForumPageState createState() => _NewForumPageState();
}

class _NewForumPageState extends State<NewForumPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final int _maxLength = 2500;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(() {
      if (_contentController.text.length > _maxLength) {
        _contentController.text = _contentController.text.substring(0, _maxLength);
        _contentController.selection = TextSelection.fromPosition(
          TextPosition(offset: _contentController.text.length),
        );
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitPost() async {
    // Check if the user is logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in')));
      return;
    }

    // Create a new Forum object with the user data
    Forum forum = Forum(
      id: '',
      userId: user.uid,
      username: user.displayName ?? 'Anonymous',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      replies: 0,
      date: Timestamp.now(),
    );

    // Call the createForumPost method to add it to Firestore
    String result = await CommunityService().createForumPost(forum);

    if (result != 'error') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post created successfully')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create post')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Discussion',
          style: TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian "Let's Talk" dari ForumPage
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
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Field Judul (Title)
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Write your forum title here',
                  hintStyle: TextStyle(fontSize: 14),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(buttonRadius),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Field Konten (Content)
              TextField(
                controller: _contentController,
                maxLines: 5,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(_maxLength),
                ],
                decoration: InputDecoration(
                  hintText: 'Write down your interesting thoughts or theories here',
                  hintStyle: TextStyle(fontSize: 14),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(buttonRadius),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${_contentController.text.length}/$_maxLength',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minimumSize: Size(100, 30),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: _submitPost,
                    child: Text(
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
    );
  }
}
