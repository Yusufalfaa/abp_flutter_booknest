import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/book_service.dart';

class BookDetailsPage extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailsPage({Key? key, required this.book}) : super(key: key);

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  bool isExpanded = false;
  bool isAdded = false; // Status untuk tombol Add/Remove
  String? userId;
  String? userBookDocId; // Store the Firestore doc ID for removal
  bool isLoading = true;
  final BookService bookService = BookService();

  @override
  void initState() {
    super.initState();
    _checkAuthAndBookStatus();
  }

  Future<void> _checkAuthAndBookStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      try {
        // Query user's books to find if this book exists (based on isbn13)
        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('books')
                .where('isbn13', isEqualTo: widget.book['isbn13'] ?? '')
                .limit(1)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            isAdded = true;
            userBookDocId =
                querySnapshot.docs.first.id; // Store doc ID for removal
          });
        }
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking book status: $e')),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleBook() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to modify your book list.'),
        ),
      );
      return;
    }

    try {
      if (isAdded) {
        // Remove book using the stored Firestore doc ID
        if (userBookDocId != null) {
          await bookService.removeBook(userId!, userBookDocId!);
          setState(() {
            isAdded = false;
            userBookDocId = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.book['title']} removed from your list!'),
            ),
          );
        }
      } else {
        // Add book
        await bookService.addBook(userId!, {
          'isbn13': widget.book['isbn13'] ?? '',
          'title': widget.book['title'] ?? 'No Title',
          'authors': widget.book['authors'] ?? 'Unknown Author',
          'categories': widget.book['categories'] ?? 'Uncategorized',
          'thumbnail': widget.book['thumbnail'] ?? '',
          'description': widget.book['description'] ?? 'No Description',
          'num_pages': widget.book['num_pages'] ?? 0,
          'published_year': widget.book['published_year'] ?? '',
          'average_rating': widget.book['average_rating'] ?? 0,
        });
        // Re-check to get the new doc ID
        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('books')
                .where('isbn13', isEqualTo: widget.book['isbn13'] ?? '')
                .limit(1)
                .get();
        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            isAdded = true;
            userBookDocId = querySnapshot.docs.first.id;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.book['title']} added to your list!'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Blurred Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.network(
                widget.book['thumbnail'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.black);
                },
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFC76E6F),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      // Card putih untuk detail buku
                      Positioned(
                        top: 160,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                          child:
                              isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Judul Buku
                                        Text(
                                          widget.book['title'] ??
                                              'Unknown Title',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Penulis Buku
                                        Text(
                                          'By ${widget.book['authors'] ?? 'Unknown'}'
                                              .toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        // Rate dan Review di atas garis
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Rating di kiri
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${widget.book['average_rating'] ?? 'N/A'}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Review di kanan
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.chat_bubble,
                                                  color: Colors.orange,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${widget.book['reviews'] ?? 0} Reviews',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Garis horizontal di bawah rate & review
                                        Divider(
                                          color: const Color(0xFFC76E6F),
                                          thickness: 2,
                                        ),
                                        const SizedBox(height: 16),
                                        // Deskripsi Buku + Tombol Expand
                                        IntrinsicHeight(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Deskripsi
                                              Expanded(
                                                child: Text(
                                                  widget.book['description'] ??
                                                      'No description available.',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                  textAlign: TextAlign.justify,
                                                  maxLines:
                                                      isExpanded ? null : 3,
                                                  overflow:
                                                      isExpanded
                                                          ? TextOverflow.visible
                                                          : TextOverflow
                                                              .ellipsis,
                                                ),
                                              ),
                                              // Tombol Expand "V"
                                              IconButton(
                                                icon: Icon(
                                                  isExpanded
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons
                                                          .keyboard_arrow_down,
                                                ),
                                                color: Colors.black,
                                                onPressed: () {
                                                  setState(() {
                                                    isExpanded = !isExpanded;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        // Genre (Tags)
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Categories",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 8,
                                                children:
                                                    (widget.book['categories']
                                                            as String?)
                                                        ?.split(',')
                                                        .map(
                                                          (genre) =>
                                                              genre.trim(),
                                                        )
                                                        .where(
                                                          (genre) =>
                                                              genre.isNotEmpty,
                                                        )
                                                        .map(
                                                          (genre) => Chip(
                                                            label: Text(
                                                              genre,
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            backgroundColor:
                                                                Colors
                                                                    .grey
                                                                    .shade300,
                                                          ),
                                                        )
                                                        .toList() ??
                                                    [],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        // Tombol "Add to List" / "Remove from List"
                                        SizedBox(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.6,
                                          child: ElevatedButton(
                                            onPressed: _toggleBook,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  isAdded
                                                      ? const Color(0xFFB0B0B0)
                                                      : const Color(0xFFC76E6F),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              shadowColor: Colors.black
                                                  .withOpacity(0.4),
                                              elevation: 6,
                                            ),
                                            child: Text(
                                              isAdded
                                                  ? 'Remove from List'
                                                  : 'Add to List',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                        ),
                      ),
                      // Cover Buku diposisikan di atas card dan di atas judul
                      Positioned(
                        top: 10,
                        left: MediaQuery.of(context).size.width * 0.5 - 75,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.book['thumbnail'] ?? '',
                            width: 150,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 150,
                                height: 220,
                                color: Colors.grey,
                                child: const Icon(Icons.broken_image, size: 50),
                              );
                            },
                          ),
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
    );
  }
}
