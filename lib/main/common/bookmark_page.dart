import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillshare_hub/main/home/widget/postcard.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookmarks"),
      ),
      backgroundColor:
          isLight ? const Color(0xFFF4F5F7) : const Color(0xff2A2E4C),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .collection("bookmarks")
            .orderBy("savedAt", descending: true)
            .snapshots(),
        builder: (context, bookmarkSnap) {
          if (!bookmarkSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookmarks = bookmarkSnap.data!.docs;

          if (bookmarks.isEmpty) {
            return Center(
              child: Text(
                "No bookmarks yet",
                style: TextStyle(
                  color: isLight ? Colors.black54 : Colors.white70,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final postId = bookmarks[index].id;

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("posts")
                    .doc(postId)
                    .snapshots(),
                builder: (context, postSnap) {
                  if (!postSnap.hasData ||
                      !postSnap.data!.exists ||
                      postSnap.data!.data() == null) {
                    return const SizedBox();
                  }

                  final post =
                      postSnap.data!.data() as Map<String, dynamic>;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Postcard(
                      postId: postId,
                      name: post["userName"] ?? "Unknown",
                      detail: post["description"] ?? "",
                      time: _formatTime(post["timestamp"]),
                      imageUrl: post["imageUrl"],
                      videoUrl: post["videoUrl"],
                      likedBy: List.from(post["likedBy"] ?? []),
                      commentCount: post["commentCount"] ?? 0,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "just now";
    final diff = DateTime.now().difference(timestamp.toDate());

    if (diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }
}
