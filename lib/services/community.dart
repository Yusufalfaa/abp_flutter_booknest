import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booknest/models/forum.dart';
import 'package:booknest/models/reply.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch forum posts sorted by replies or date
  Future<List<Forum>> getForumPosts({bool byReplies = true}) async {
    try {
      QuerySnapshot querySnapshot;

      if (byReplies) {
        querySnapshot = await _firestore
            .collection('forums')
            .orderBy('replies', descending: true)
            .get();
      } else {
        querySnapshot = await _firestore
            .collection('forums')
            .orderBy('date', descending: true)
            .get();
      }

      // Map Firestore documents to Forum model
      return querySnapshot.docs.map((doc) {
        return Forum.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error getting forum posts: $e");
      return [];
    }
  }

  // Add a new forum post
  Future<String> createForumPost(Forum forum) async {
    try {
      // Add a new forum post with current timestamp
      DocumentReference docRef = await _firestore.collection('forums').add({
        'userId': forum.userId,
        'username': forum.username,
        'title': forum.title,
        'content': forum.content,
        'replies': forum.replies,
        'date': FieldValue.serverTimestamp(), // Use server timestamp here
      });

      return docRef.id; // Return the newly created forum's document ID
    } catch (e) {
      print("Error creating forum post: $e");
      return "error";
    }
  }

  // Add a reply to a forum post
  Future<String> addReplyToPost(String postId, Reply reply) async {
    try {
      // Reference to the specific forum post
      DocumentReference postRef = _firestore.collection('forums').doc(postId);

      // Add a reply as a new document in the 'replies' sub-collection
      await postRef.collection('replies').add({
        'userId': reply.userId,
        'username': reply.username,
        'content': reply.content,
        'date': FieldValue.serverTimestamp(), // Store server timestamp for reply
      });

      // Optionally, update the main post document with the number of replies
      await postRef.update({
        'replies': FieldValue.increment(1),
      });

      return "success";
    } catch (e) {
      print("Error adding reply: $e");
      return "error";
    }
  }

  // Fetch replies for a particular post
  Future<List<Reply>> getRepliesForPost(String postId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('forums')
          .doc(postId)
          .collection('replies')
          .orderBy('date', descending: true)
          .get();

      // Map Firestore documents to Reply model
      return querySnapshot.docs.map((doc) {
        return Reply.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error fetching replies: $e");
      return [];
    }
  }
}
