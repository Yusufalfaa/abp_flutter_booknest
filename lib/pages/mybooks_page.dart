import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyBooksPage extends StatefulWidget {
  const MyBooksPage({super.key});

  @override
  _MyBooksPageState createState() => _MyBooksPageState();
}

class _MyBooksPageState extends State<MyBooksPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _removeBook(String bookId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('books')
          .doc(bookId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Books")),
        body: const Center(child: Text("Please sign in to view your books.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Books")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('books')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No books added yet."));
          }

          var books = snapshot.data!.docs;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              var book = books[index].data() as Map<String, dynamic>;
              String bookId = books[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading:
                      book['thumbnail'] != null
                          ? Image.network(
                            book['thumbnail'],
                            width: 50,
                            height: 75,
                            fit: BoxFit.cover,
                          )
                          : const Icon(Icons.book, size: 50),
                  title: Text(book['title'] ?? 'No Title'),
                  subtitle: Text(book['authors'] ?? 'Unknown Author'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeBook(bookId),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
