import 'package:cloud_firestore/cloud_firestore.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getUserBooks(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .snapshots();
  }

  Future<void> addBook(String userId, Map<String, dynamic> bookData) async {
    if (userId.isEmpty) throw Exception("Invalid user ID");

    // Ensure required fields are present
    if (!bookData.containsKey('title') || !bookData.containsKey('isbn13')) {
      throw Exception("Book data must include at least 'title' and 'isbn13'");
    }

    await _firestore.collection('users').doc(userId).collection('books').add({
      ...bookData, // Spread operator to include all book fields
      'addedAt': FieldValue.serverTimestamp(), // Optional timestamp
    });

    print("Added book: ${bookData['title']} to user: $userId");
  }

  Future<void> removeBook(String userId, String bookId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .delete();
  }
}
