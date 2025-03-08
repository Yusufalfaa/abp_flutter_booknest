import 'package:booknest/models/user.dart' as model;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user obj based on Firebase User
  model.User? _userFromFirebaseUser(auth.User? user,
      Map<String, dynamic>? userData) {
    if (user == null || userData == null) return null;

    return model.User(
      uid: user.uid,
      username: userData["username"] ?? "",
      email: user.email ?? "",
    );
  }

  // Auth change user stream
  Stream<model.User?> get user {
    return _auth.authStateChanges().asyncMap((auth.User? user) async {
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore.collection("users")
          .doc(user.uid)
          .get();
      return _userFromFirebaseUser(user, doc.data() as Map<String, dynamic>?);
    });
  }

  // Sign Up (Register)
  Future<model.User?> signUp({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      if (password != passwordConfirmation) {
        throw Exception("Passwords do not match!");
      }

      // Create user in Firebase Authentication
      auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      auth.User? user = result.user;
      if (user == null) return null;

      // Save user data to Firestore
      Map<String, dynamic> userData = {
        "username": username,
        "email": email,
        "uid": user.uid,
        "createdAt": FieldValue.serverTimestamp(),
      };

      await _firestore.collection("users").doc(user.uid).set(userData);

      // Combine data from Firebase Authentication and Firestore
      return _userFromFirebaseUser(user, userData);
    } catch (e) {
      print("Error during sign up: $e");
      return null;
    }
  }

  // Sign In (Login)
  Future<model.User?> signInWithEmailAndPassword(String email,
      String password) async {
    try {
      // Sign in with Firebase Authentication
      auth.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      auth.User? user = result.user;
      if (user == null) return null;

      // Retrieve user data from Firestore
      DocumentSnapshot doc = await _firestore.collection("users")
          .doc(user.uid)
          .get();
      return _userFromFirebaseUser(user, doc.data() as Map<String, dynamic>?);
    } catch (e) {
      print("Error during sign in: $e");
      return null;
    }
  }

  // Sign In with Google
  Future<model.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;

      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      auth.UserCredential userCredential = await _auth.signInWithCredential(
          credential);
      auth.User? user = userCredential.user;

      if (user != null) {
        // Store user data in Firestore if it's the first time login
        await _createUserInFirestore(user);
        return _userFromFirebaseUser(user, {
          "username": user.displayName ?? "Unknown",
          "email": user.email ?? "Unknown",
          "uid": user.uid,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      return null;
    } catch (e) {
      print("Error during Google sign-in: $e");
      return null;
    }
  }

  // Sign Out (Logout)
  Future<void> signOut() async {
    try {
      // Sign out from Firebase Authentication
      await _auth.signOut();

      // Sign out from Google as well
      await GoogleSignIn().signOut();

      print("User signed out from both Firebase and Google.");
    } catch (e) {
      print("Error during sign out: $e");
    }
  }


  Future<void> _createUserInFirestore(auth.User user) async {
    try {
      // Check if the user already exists in Firestore
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(
          user.uid).get();
      if (!userDoc.exists) {
        // If the user doesn't exist, create a new document
        await _firestore.collection("users").doc(user.uid).set({
          "username": user.displayName ?? "Unknown",
          "email": user.email ?? "Unknown",
          "uid": user.uid,
          "createdAt": FieldValue.serverTimestamp(),
        });
        print("User data saved to Firestore.");
      } else {
        print("User already exists in Firestore.");
      }
    } catch (e) {
      print("Error while saving user data to Firestore: $e");
    }
  }
}
