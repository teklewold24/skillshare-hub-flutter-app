import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:skillshare_hub/controllers/model/post_model.dart';

part 'postcontroller.g.dart';

@riverpod
class Postcontroller extends _$Postcontroller {
  @override
  PostModel build() {
    ref.keepAlive();
    return const PostModel();
  }

  void setDescription(String v) {
    state = state.copyWith(description: v);
  }

  void setImage(String url) {
    state = state.copyWith(imageUrl: url);
  }

  void setVideo(String url) {
    state = state.copyWith(videoUrl: url);
  }

  void reset() {
    state = const PostModel();
  }

  
  Future<String> _uploadFile(File file, String folderName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Not logged in");

      final fileName =
          "${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final ref = FirebaseStorage.instance
          .ref()
          .child(folderName)
          .child(fileName);

      final taskSnapshot = await ref.putFile(file);

      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print("UPLOAD ERROR → $e");
      throw Exception("Failed to upload file");
    }
  }

  Future<void> saveToFirestore(File? mediaFile, bool isVideo) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      final userData = userDoc.data()!;

      String mediaUrl = "";

      if (mediaFile != null) {
        mediaUrl = await _uploadFile(
          mediaFile,
          isVideo ? "videos" : "images",
        );
      }

      final postRef = FirebaseFirestore.instance.collection("posts").doc();

      final postData = {
        "uid": user.uid,
        "userName": userData["firstname"],
        "description": state.description.trim(),
        "imageUrl": isVideo ? "" : mediaUrl,
        "videoUrl": isVideo ? mediaUrl : "",
        "likes": 0,
        "likedBy": [],
        "commentCount": 0,
        "timestamp": FieldValue.serverTimestamp(),
      };

      await postRef.set(postData);

      reset();
    } catch (e) {
      print("POST ERROR → $e");
      throw Exception("Failed to publish post");
    }
  }

  Future<void> toggleLike(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(postRef);
      if (!snap.exists) return;

      final data = snap.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      final already = likedBy.contains(uid);

      if (already) {
        tx.update(postRef, {
          'likedBy': FieldValue.arrayRemove([uid]),
          'likes': FieldValue.increment(-1),
        });
      } else {
        tx.update(postRef, {
          'likedBy': FieldValue.arrayUnion([uid]),
          'likes': FieldValue.increment(1),
        });
      }
    });
  }

  Future<void> addReply({
    required String postId,
    required String commentId,
    required String text,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || text.trim().isEmpty) return;

    final replyRef = FirebaseFirestore.instance
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .doc(commentId)
        .collection("replies")
        .doc();

    await replyRef.set({
      "id": replyRef.id,
      "uid": user.uid,
      "text": text.trim(),
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Future<void> addComment(String postId, String commentText) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not logged in');

    final trimmed = commentText.trim();
    if (trimmed.isEmpty) return;

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final commentRef = postRef.collection('comments').doc();

    final batch = FirebaseFirestore.instance.batch();
    batch.set(commentRef, {
      'id': commentRef.id,
      'uid': user.uid,
      'text': trimmed,
      'timestamp': FieldValue.serverTimestamp(),
    });
    batch.update(postRef, {
      'commentCount': FieldValue.increment(1),
    });

    await batch.commit();
  }
}
