import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/all_books_page.dart';
import '../pages/forum_page.dart';
import '../pages/mybooks_page.dart';
import '../pages/faq_page.dart';
import 'package:booknest/services/auth.dart';

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
    "Action", "Fantasy", "Romance", "Comic", "History", "Poetry", "Thriller"
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
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);

                // Show a SnackBar notification upon successful logout
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('You have successfully logged out!')),
                );
              },
              child: const Text("Log Out", style: TextStyle(color: primaryColor)),
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
      body: _isFaqPage
          ? const FaqPage()
          : (_selectedIndex == 0 ? _buildHomeContent() : _pages[_selectedIndex]),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'All Books'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'MyBooks'),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: lightColor,
        selectedItemColor: _isFaqPage? blackColor : primaryColor,
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
        child: const Text('?', style: TextStyle(fontSize: 24, color: Colors.white)),
      ),
    );
  }

  // Home Page Content
  Widget _buildHomeContent() {
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
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          const Text("We sorted the best for you", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _buildBookRecommendation(),
          ...categories.map((category) => _buildCategorySection(category)).toList(),
        ],
      ),
    );
  }

  Widget _buildBookRecommendation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(buttonRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 110,
                      color: Colors.grey[400],
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/imagetes1.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Just to put it out there, I'll admit straight off the bat that I'm one of the people who enjoyed this book.",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            onPressed: () {},
                            child: const Text("Add to List", style: TextStyle(fontSize: 12, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonRadius),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () {},
                child: const Text("View All", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 10),
                color: Colors.grey,
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/imagetes1.jpg',
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
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
            title: Center(child: Image.asset("assets/BookNest.png", height: 30)),
          ),
          const Divider(thickness: 1, color: Colors.grey),
          Expanded(
            child: ListView(
              children: _currentUser == null
                  ? [
                _buildDrawerItem(context, 'Sign In', '/sign-in', Icons.login),
                _buildDrawerItem(context, 'Settings', '/settings', Icons.settings),
              ]
                  : [
                _buildDrawerItem(context, 'Profile', '/profile', Icons.person),
                ListTile(
                  title: const Text('Log Out', style: TextStyle(color: blackColor)),
                  leading: Icon(Icons.login, color: blackColor),
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
                _buildDrawerItem(context, 'Settings', '/settings', Icons.settings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, String route, IconData icon) {
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
