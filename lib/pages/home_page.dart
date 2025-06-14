import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/all_books_page.dart';
import '../pages/forum_page.dart';
import '../pages/mybooks_page.dart';
import '../pages/faq_page.dart';
import '../pages/book_detail_page.dart';
import '../services/book_service.dart';
import '../pages/genre_page.dart';
import 'package:booknest/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color lightColor = Color(0xFFF1EFE3);
const Color backgroundColor = Color(0xFFF8F8F8);
const Color primaryColor = Color(0xFFC76E6F);
const Color blackColor = Color(0xFF272727);
const double buttonRadius = 12.0;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isFaqPage = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  final List<Widget> _pages = [
    const Placeholder(),
    const AllBooksPage(),
    const ForumPage(),
    const MyBooksPage(),
  ];

  final List<String> categories = [
    "Fiction",
    "Drama",
    "Philosophy",
    "History",
    "Poetry",
    "Science",
  ];

  void _openFaqPage() {
    setState(() {
      _isFaqPage = true;
    });
  }

  // Logout Alert
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: lightColor,
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await AuthService().signOut();
                setState(() {
                  _currentUser = null;
                });
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );

                // Show a SnackBar notification upon successful logout
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('You have successfully logged out!')),
                );
              },
              child: const Text(
                "Log Out",
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: lightColor,
        title: Image.asset("assets/BookNest.png", height: 40),
      ),
      endDrawer: _buildDrawer(context),
      body:
          _isFaqPage
              ? const FaqPage()
              : (_selectedIndex == 0
                  ? _buildHomeContent()
                  : _pages[_selectedIndex]),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'MyBooks'),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: lightColor,
        selectedItemColor: _isFaqPage ? blackColor : primaryColor,
        unselectedItemColor: blackColor,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        onTap: (index) {
          setState(() {
            _isFaqPage = false;
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _openFaqPage,
        shape: const CircleBorder(),
        child: const Text(
          '?',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage("assets/bgDarker.png"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text(
              "Find and rate your best book",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "We sorted the best for you",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (userId != null) _buildRandomBooks(userId),
          ...categories
              .map((category) => _buildCategorySection(category))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildRandomBooks(String userId) {
    final BookService bookService = BookService();
    const double buttonRadius = 30; // Define if not global
    const Color primaryColor = Color(0xFFC76E6F); // Red from BookDetailsPage
    const Color removeColor = Color(0xFFB0B0B0); // Grey from BookDetailsPage

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.microtask(() async {
        try {
          // Fetch up to 20 books to allow shuffling (increase if needed)
          final booksSnapshot =
              await FirebaseFirestore.instance
                  .collection('books')
                  .limit(20)
                  .get();
          final allBooks =
              booksSnapshot.docs
                  .map(
                    (doc) => {
                      'id': doc.id,
                      ...doc.data() as Map<String, dynamic>,
                    },
                  )
                  .toList()
                ..shuffle(); // Randomize

          // Limit to 8 books
          final randomBooks = allBooks.take(8).toList();

          // Check added status for each book
          final booksWithStatus = <Map<String, dynamic>>[];
          for (var book in randomBooks) {
            final isbn = book['isbn13'] ?? book['id'];
            String? docId;
            if (userId.isNotEmpty) {
              final userBookSnapshot =
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('books')
                      .where('isbn13', isEqualTo: isbn)
                      .limit(1)
                      .get();
              if (userBookSnapshot.docs.isNotEmpty) {
                docId = userBookSnapshot.docs.first.id;
              }
            }
            booksWithStatus.add({
              ...book,
              'isAdded': docId != null,
              'userBookDocId': docId,
            });
          }

          return booksWithStatus;
        } catch (e) {
          print('Error fetching books: $e'); // Log for debugging
          return [];
        }
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No books available'));
        }

        final books = snapshot.data!;
        final itemCount = books.length;

        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final book = books[index];
              final bookId = book['isbn13'] ?? book['id'];
              final isAdded = book['isAdded'] as bool;
              final userBookDocId = book['userBookDocId'] as String?;

              return Container(
                width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(buttonRadius),
                  /*boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],*/
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 110,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(book['thumbnail'] ?? ''),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            book['title'] ?? 'No Title',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            book['description'] != null &&
                                    book['description'].length > 50
                                ? '${book['description'].substring(0, 50)} ...'
                                : (book['description'] ??
                                    'Unknown Description'),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isAdded ? removeColor : primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  buttonRadius,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                            onPressed: () async {
                              if (userId.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please log in to modify your book list.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              try {
                                if (isAdded && userBookDocId != null) {
                                  // Remove book
                                  await bookService.removeBook(
                                    userId,
                                    userBookDocId,
                                  );
                                  setState(() {
                                    book['isAdded'] = false;
                                    book['userBookDocId'] = null;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "${book['title']} removed from your list!",
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  // Add book
                                  await bookService.addBook(userId, {
                                    'isbn13': book['isbn13'] ?? book['id'],
                                    'title': book['title'] ?? 'No Title',
                                    'authors':
                                        book['authors'] ?? 'Unknown Author',
                                    'categories':
                                        book['categories'] ?? 'Uncategorized',
                                    'thumbnail': book['thumbnail'] ?? '',
                                    'description':
                                        book['description'] ?? 'No Description',
                                  });
                                  // Fetch new doc ID
                                  final userBookSnapshot =
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userId)
                                          .collection('books')
                                          .where('isbn13', isEqualTo: bookId)
                                          .limit(1)
                                          .get();
                                  if (userBookSnapshot.docs.isNotEmpty) {
                                    setState(() {
                                      book['isAdded'] = true;
                                      book['userBookDocId'] =
                                          userBookSnapshot.docs.first.id;
                                    });
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "${book['title']} added to your list!",
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to modify book: ${e.toString()}',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              isAdded ? 'Remove from List' : 'Add to List',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            category,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('books')
                  .where('categories', isEqualTo: category)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var books = snapshot.data!.docs;
            int maxBooks = 10;
            int itemCount = books.length > maxBooks ? maxBooks : books.length;

            return SizedBox(
              height: 168,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: itemCount + 1,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (context, index) {
                  if (index < itemCount) {
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
                        width: 100,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                book['thumbnail'] ?? '',
                                width: 100,
                                height: 140,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Title of the book
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
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
                  } else {
                    return SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(buttonRadius),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () {
                          // Navigate to a full category page if needed
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GenrePage(genre: category),
                            ),
                          );
                        },
                        child: const Text(
                          "View All",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          ListTile(
            title: Center(
              child: Image.asset("assets/BookNest.png", height: 30),
            ),
          ),
          const Divider(thickness: 1, color: Colors.grey),
          Expanded(
            child: ListView(
              children:
                  _currentUser == null
                      ? [
                        _buildDrawerItem(
                          context,
                          'Sign In',
                          '/sign-in',
                          Icons.login,
                        ),
                        _buildDrawerItem(
                          context,
                          'Settings',
                          '/settings',
                          Icons.settings,
                        ),
                      ]
                      : [
                        _buildDrawerItem(
                          context,
                          'Profile',
                          '/profile',
                          Icons.person,
                        ),
                        ListTile(
                          title: const Text(
                            'Log Out',
                            style: TextStyle(color: blackColor),
                          ),
                          leading: Icon(Icons.login, color: blackColor),
                          onTap: () {
                            _showLogoutDialog(context);
                          },
                        ),
                        _buildDrawerItem(
                          context,
                          'Settings',
                          '/settings',
                          Icons.settings,
                        ),
                      ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    String route,
    IconData icon,
  ) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: blackColor)),
      leading: Icon(icon, color: blackColor),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}
