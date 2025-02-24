import 'package:booknest/models/user.dart' as model;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user obj based on Firebase User
  model.User? _userFromFirebaseUser(auth.User? user, Map<String, dynamic>? userData) {
    if (user == null || userData == null) return null;

    return model.User(
      uid: user.uid,
      firstName: userData["firstName"] ?? "",
      lastName: userData["lastName"] ?? "",
      username: userData["username"] ?? "",
      email: user.email ?? "",
    );
  }

  // Auth change user stream
  Stream<model.User?> get user {
    return _auth.authStateChanges().asyncMap((auth.User? user) async {
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore.collection("users").doc(user.uid).get();
      return _userFromFirebaseUser(user, doc.data() as Map<String, dynamic>?);
    });
  }

  // Sign Up (Register)
  Future<model.User?> signUp({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      if (password != passwordConfirmation) {
        throw Exception("Passwords do not match!");
      }

      auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      auth.User? user = result.user;
      if (user == null) return null;

      // Simpan data pengguna ke Firestore
      Map<String, dynamic> userData = {
        "firstName": firstName,
        "lastName": lastName,
        "username": username,
        "email": email,
        "uid": user.uid,
        "createdAt": FieldValue.serverTimestamp(),
      };

      await _firestore.collection("users").doc(user.uid).set(userData);

      return _userFromFirebaseUser(user, userData);
    } catch (e) {
      print("Error during sign up: $e");
      return null;
    }
  }

  // Sign In (Login)
  Future<model.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      auth.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      auth.User? user = result.user;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore.collection("users").doc(user.uid).get();
      return _userFromFirebaseUser(user, doc.data() as Map<String, dynamic>?);
    } catch (e) {
      print("Error during sign in: $e");
      return null;
    }
  }

  // Sign In (Google)
  Future<auth.UserCredential?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      return null;
    }
  }


  // Sign Out (Logout)
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error during sign out: $e");
    }
  }
}
