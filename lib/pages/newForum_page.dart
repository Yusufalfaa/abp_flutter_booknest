import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:booknest/pages/home_page.dart';

class NewForumPage extends StatefulWidget {
  const NewForumPage({super.key});

  @override
  _NewForumPageState createState() => _NewForumPageState();
}

class _NewForumPageState extends State<NewForumPage> {
  final TextEditingController _contentController = TextEditingController();
  final int _maxLength = 2500; // Batas maksimum karakter

  @override
  void initState() {
    super.initState();
    // Listener untuk update UI dan batasi panjang teks
    _contentController.addListener(() {
      if (_contentController.text.length > _maxLength) {
        // Potong teks jika melebihi 2500 karakter
        _contentController.text = _contentController.text.substring(0, _maxLength);
        // Posisikan kursor di akhir teks
        _contentController.selection = TextSelection.fromPosition(
          TextPosition(offset: _contentController.text.length),
        );
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
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
                    "Sharing, find support, and connect with community",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Field Judul (tanpa label "Title")
              TextField(
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

              // Field Konten
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

              // Baris untuk counter dan tombol Post di luar TextField
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
                    onPressed: () {},
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