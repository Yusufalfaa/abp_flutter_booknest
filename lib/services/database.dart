import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booknest/models/user.dart';
import 'package:booknest/models/book.dart';

class DatabaseService {
  final String uid;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  DatabaseService({required this.uid});

  // Collection References
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference bookCollection = FirebaseFirestore.instance.collection('books');

  // Update User Data
  Future<void> updateUserData(String firstName, String lastName, String username, String email) async {
    try {
      await userCollection.doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
      });
    } catch (e) {
      print("Error updating user data: $e");
    }
  }

  // Change User Password
  Future<void> updateUserPassword(String currentPassword, String newPassword) async {
    try {
      auth.User? user = _auth.currentUser;

      if (user != null) {
        // Re-authenticate the user to ensure they are the correct one making the change
        auth.AuthCredential credential = auth.EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        // Reauthenticate the user
        await user.reauthenticateWithCredential(credential);

        // Once re-authenticated, update the password
        await user.updatePassword(newPassword);
        await user.reload(); // Reload the user to apply changes
        print("Password changed successfully");
      }
    } catch (e) {
      print("Error changing password: $e");
      throw e;
    }
  }

  // Get User Data
  Future<User> getUserData() async {
    try {
      DocumentSnapshot userSnapshot = await userCollection.doc(uid).get();
      return User.fromMap(userSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      print("Error getting user data: $e");
      rethrow;
    }
  }

  // Add Book to Firestore
  Future<void> addBook(Book book) async {
    try {
      await bookCollection.add(book.toMap());
    } catch (e) {
      print("Error adding book: $e");
    }
  }

  // Get Books Data
  Future<List<Book>> getBooks() async {
    try {
      QuerySnapshot snapshot = await bookCollection.get();
      return snapshot.docs.map((doc) => Book.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Error getting books: $e");
      return [];
    }
  }


}
