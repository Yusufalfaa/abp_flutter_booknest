import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:booknest/models/forum.dart';
import 'package:booknest/models/reply.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch forum posts sorted by either replies or date
  Future<List<Forum>> getForumPosts({bool byReplies = true}) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('forums')
          .orderBy(byReplies ? 'replies' : 'date', descending: true)
          .limit(10)
          .get();

      List<Forum> forumList = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final postId = doc.id;

        // Hitung reply secara akurat
        final replySnapshot = await FirebaseFirestore.instance
            .collection('forums')
            .doc(postId)
            .collection('replies')
            .get();

        int actualReplies = replySnapshot.docs.length;

        forumList.add(Forum.fromMap({
          'id': postId,
          ...data,
          'replies': actualReplies, // override field replies
        }));
      }

      return forumList;
    } catch (e) {
      print("Error getting forum posts: $e");
      return [];
    }
  }


  // Fetch a single forum post by ID
  Future<Forum> getForumPostById(String postId) async {
    try {
      DocumentSnapshot docSnapshot = await _firestore.collection('forums').doc(postId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return Forum.fromMap({
          'id': docSnapshot.id,
          ...data,
        });
      } else {
        throw Exception('Forum post not found');
      }
    } catch (e) {
      print("Error getting forum post by ID: $e");
      rethrow;
    }
  }

  // Fetch a single forum post by ID
  Future<Map<String, String>> getAvatarUrlsForUserIds(List<String> userIds) async {
    Map<String, String> avatarUrls = {};

    if (userIds.isEmpty) return avatarUrls;

    // Firestore batasi whereIn maksimal 10 items per query
    const int batchSize = 10;
    for (int i = 0; i < userIds.length; i += batchSize) {
      final end = (i + batchSize > userIds.length) ? userIds.length : i + batchSize;
      final batch = userIds.sublist(i, end);

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        avatarUrls[doc.id] = data['avatar'] ?? "";
      }
    }

    return avatarUrls;
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

  // Delete a forum post by ID
  Future<void> deleteForumPost(String postId) async {
    try {
      QuerySnapshot repliesSnapshot = await _firestore
          .collection('forums')
          .doc(postId)
          .collection('replies')
          .get();

      for (var reply in repliesSnapshot.docs) {
        await reply.reference.delete();
      }

      await _firestore.collection('forums').doc(postId).delete();
    } catch (e) {
      print("Error deleting forum post: $e");
    }
  }

  // Delete a reply by ID from the specific forum post's replies subcollection
  Future<void> deleteReply(String postId, String replyId) async {
    try {
      DocumentReference postRef = FirebaseFirestore.instance.collection('forums').doc(postId);

      await postRef.collection('replies').doc(replyId).delete();

      QuerySnapshot repliesSnapshot = await postRef.collection('replies').get();
      int repliesCount = repliesSnapshot.docs.length;

      await postRef.update({
        'replies': repliesCount,
      });
    } catch (e) {
      print("Error deleting reply: $e");
      throw e;
    }
  }


}
