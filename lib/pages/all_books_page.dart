import 'package:booknest/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_detail_page.dart';

class AllBooksPage extends StatefulWidget {
  const AllBooksPage({super.key});

  @override
  _AllBooksPageState createState() => _AllBooksPageState();
}

class _AllBooksPageState extends State<AllBooksPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 380,
                height: 40,
                margin: const EdgeInsets.only(top: 16),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    hintText: 'Book Title',
                    filled: true,
                    fillColor: const Color(0xFFF1EFE3),
                    suffixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Show books only when there's a search query
            Expanded(
              child: _searchQuery.isEmpty
                  ? const Center(
                child: Text(
                  'Please enter a book title to search',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('books')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var books = snapshot.data!.docs.where((doc) {
                    var book = doc.data() as Map<String, dynamic>;
                    return book['title']
                        .toString()
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
                  }).toList();

                  if (books.isEmpty) {
                    return const Center(
                      child: Text(
                        'Book not found',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: books.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      var book = books[index].data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailsPage(book: book),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  book['thumbnail'] ?? '',
                                  width: double.infinity,
                                  height: 160,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: 160,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.book, size: 50),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8, left: 4, right: 4, bottom: 8),
                                child: Text(
                                  book['title'] ?? 'No Title',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ),
                            ],
                          ),
                        ),
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