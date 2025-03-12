import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:booknest/models/forum.dart';
import 'package:booknest/models/reply.dart';


class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Forum>> getForumPosts({bool byReplies = true}) async {
    try {
      QuerySnapshot querySnapshot;

      if (byReplies) {
        querySnapshot = await FirebaseFirestore.instance
            .collection('forums')
            .orderBy('replies', descending: true)
            .limit(10)
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('forums')
            .orderBy('date', descending: true)
            .limit(10)
            .get();
      }

      print("Documents Retrieved: ${querySnapshot.docs.length}");

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print("Forum Data: $data");

        return Forum.fromMap({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      print("Error getting forum posts: $e");
      return [];
    }
  }

  // Add a new forum post
  Future<String> createForumPost(Forum forum) async {
    try {
      // Ambil username dari Firebase Auth
      User? user = FirebaseAuth.instance.currentUser;
      String username;

      if (user != null) {
        // Ambil username dari Firestore jika tidak ada di FirebaseAuth
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        username = userDoc['username'] ?? user.email ?? 'Anonymous';
      } else {
        username = 'Anonymous';
      }

      // Add a new forum post with current timestamp
      DocumentReference docRef = await _firestore.collection('forums').add({
        'userId': forum.userId,
        'username': username,
        'title': forum.title,
        'content': forum.content,
        'replies': forum.replies,
        'date': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print("Error creating forum post: $e");
      return "error";
    }
  }

  // Add a reply to a forum post
  Future<String> addReplyToPost(String postId, Reply reply) async {
    try {
      // Ambil user yang sedang login dari FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;
      String username;

      if (user != null) {
        // Ambil username dari Firestore jika tidak ada di FirebaseAuth
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        username = userDoc['username'] ?? user.email ?? 'Anonymous';
      } else {
        username = 'Anonymous';
      }

      // Menambahkan reply ke dalam post yang sudah ada
      DocumentReference postRef = _firestore.collection('forums').doc(postId);

      DocumentReference replyRef = await postRef.collection('replies').add({
        'userId': reply.userId,
        'username': username,
        'content': reply.content,
        'date': FieldValue.serverTimestamp(),
      });

      // Update jumlah replies pada forum post
      await postRef.update({'replies': FieldValue.increment(1)});

      return replyRef.id;
    } catch (e) {
      print("Error adding reply: $e");
      return "error";
    }
  }

  // Fetch replies for a particular post using a Stream
  Stream<List<Reply>> getRepliesForPost(String postId) {
    return _firestore
        .collection('forums')
        .doc(postId)
        .collection('replies')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Reply.fromMap({
          'id': doc.id,
          ...data,
        });
      }).toList();
    });
  }

}
