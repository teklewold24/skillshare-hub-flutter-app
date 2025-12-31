import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillshare_hub/controllers/provider/post_provider/postcontroller.dart';

class Postcard extends ConsumerWidget {
  final String postId;
  final String name;
  final String detail;
  final String time;
  final String? imageUrl;
  final String? videoUrl;
  final List likedBy;
  final int commentCount;

  const Postcard({
    super.key,
    required this.postId,
    required this.name,
    required this.detail,
    required this.time,
    this.imageUrl,
    this.videoUrl,
    required this.likedBy,
    required this.commentCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isLight
            ? Colors.white
            : const Color.fromARGB(80, 255, 255, 255),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLight ? Colors.grey.shade300 : Colors.white24,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("posts")
                .doc(postId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const SizedBox();
              }

              final raw = snapshot.data!.data();
              if (raw == null) return const SizedBox();

              final data = raw as Map<String, dynamic>;
              final isOwner = data["uid"] == currentUid;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(name),
                subtitle: Text(time),
                trailing: isOwner
                    ? PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == "delete") {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Delete Post"),
                                content: const Text(
                                    "Are you sure you want to delete this post?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await FirebaseFirestore.instance
                                  .collection("posts")
                                  .doc(postId)
                                  .delete();
                            }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: "delete",
                            child: Text("Delete"),
                          ),
                        ],
                      )
                    : null,
              );
            },
          ),

          Text(detail),

          const SizedBox(height: 10),

         
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("posts")
                .doc(postId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const SizedBox();
              }

              final raw = snapshot.data!.data();
              if (raw == null) return const SizedBox();

              final data = raw as Map<String, dynamic>;
              final likedBy =
                  List<String>.from(data["likedBy"] ?? []);
              final isLiked = likedBy.contains(currentUid);
              final commentCount =
                  data["commentCount"] ?? 0;

              return Row(
                children: [
                  
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(postcontrollerProvider.notifier)
                          .toggleLike(postId);
                    },
                    child: Row(
                      children: [
                        Icon(
                          isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey,
                        ),
                        Text(likedBy.length.toString()),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  
                  GestureDetector(
                    onTap: () => _openCommentSheet(context, ref),
                    child: Row(
                      children: [
                        const Icon(Icons.comment),
                        Text(commentCount.toString()),
                      ],
                    ),
                  ),

                  const Spacer(),

                  
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(currentUid)
                        .collection("bookmarks")
                        .doc(postId)
                        .snapshots(),
                    builder: (context, snap) {
                      final isBookmarked =
                          snap.data?.exists ?? false;

                      return GestureDetector(
                        onTap: () async {
                          final ref = FirebaseFirestore.instance
                              .collection("users")
                              .doc(currentUid)
                              .collection("bookmarks")
                              .doc(postId);

                          if (isBookmarked) {
                            await ref.delete();
                          } else {
                            await ref.set({
                              "postId": postId,
                              "savedAt":
                                  FieldValue.serverTimestamp(),
                            });
                          }
                        },
                        child: Icon(
                          isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: Colors.blue,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

 

  
  void _openCommentSheet(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    height: 5,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("posts")
                          .doc(postId)
                          .collection("comments")
                          .orderBy("timestamp", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text("No comments yet"));
                        }

                        return ListView(
                          controller: scrollController,
                          children: snapshot.data!.docs.map((doc) {
                            final data =
                                doc.data() as Map<String, dynamic>;
                            return _CommentTile(
                              postId: postId,
                              commentId: doc.id,
                              commentText: data["text"],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                hintText: "Add a comment...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send,
                                color: Colors.blue),
                            onPressed: () async {
                              if (controller.text.trim().isEmpty)
                                return;

                              await ref
                                  .read(postcontrollerProvider.notifier)
                                  .addComment(
                                      postId, controller.text);

                              controller.clear();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CommentTile extends ConsumerStatefulWidget {
  final String postId;
  final String commentId;
  final String commentText;

  const _CommentTile({
    required this.postId,
    required this.commentId,
    required this.commentText,
  });

  @override
  ConsumerState<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends ConsumerState<_CommentTile> {
  bool showReplyInput = false;
  bool showReplies = false;

  final replyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          ListTile(
            leading: const CircleAvatar(radius: 16),
            title: Text(widget.commentText),
            trailing: TextButton(
              onPressed: () {
                setState(() => showReplyInput = !showReplyInput);
              },
              child: const Text("Reply"),
            ),
          ),

          
          if (showReplyInput)
            Padding(
              padding: const EdgeInsets.only(left: 60),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: replyController,
                      decoration: const InputDecoration(
                        hintText: "Write a reply...",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () async {
                      if (replyController.text.trim().isEmpty) return;

                      await ref
                          .read(postcontrollerProvider.notifier)
                          .addReply(
                            postId: widget.postId,
                            commentId: widget.commentId,
                            text: replyController.text.trim(),
                          );

                      replyController.clear();
                      setState(() => showReplyInput = false);
                    },
                  ),
                ],
              ),
            ),

          
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("posts")
                .doc(widget.postId)
                .collection("comments")
                .doc(widget.commentId)
                .collection("replies")
                .orderBy("timestamp", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox();
              }

              final replies = snapshot.data!.docs;

              return Padding(
                padding: const EdgeInsets.only(left: 60, top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => showReplies = !showReplies);
                      },
                      child: Text(
                        showReplies
                            ? "Hide replies"
                            : "View replies (${replies.length})",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    if (showReplies)
                      Column(
                        children: replies.map((doc) {
                          final data =
                              doc.data() as Map<String, dynamic>;
                          return ListTile(
                            dense: true,
                            leading:
                                const CircleAvatar(radius: 10),
                            title: Text(data["text"] ?? ""),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
