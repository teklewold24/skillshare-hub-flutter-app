import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillshare_hub/main/message/chatdetail.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

   
    final background = isLight
        ? const Color(0xFFF4F5F7) 
        : const Color.fromARGB(255, 42, 46, 76);

    final cardColor = isLight
        ? Colors.white
        : const Color.fromARGB(255, 60, 65, 100);

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Text(
          "Messages",
          style: TextStyle(
            color: isLight ? Colors.black : Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isLight ? Colors.black : Colors.white,
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("chats")
            .where("users", arrayContains: user.uid)
            .orderBy("lastMessageAt", descending: true)
            .snapshots(includeMetadataChanges: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No conversations yet",
                style: TextStyle(
                  color: isLight ? Colors.black54 : Colors.white70,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final List users = data["users"];
              final String otherUserId =
                  users.firstWhere((id) => id != user.uid);

              final int unread =
                  (data["unread"]?[user.uid] ?? 0) as int;

              final Timestamp? ts = data["lastMessageAt"];
              final String timeText =
                  ts == null ? "" : _formatTime(ts.toDate());

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailPage(
                        chatId: doc.id,
                        otherUserId: otherUserId,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isLight
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: isLight
                            ? Colors.grey.shade300
                            : Colors.white24,
                        child: Icon(
                          Icons.person,
                          color: isLight ? Colors.black : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),

                   
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _UserName(
                              userId: otherUserId,
                              isLight: isLight,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data["lastMessage"]
                                              ?.toString()
                                              .isEmpty ??
                                          true
                                  ? "No messages yet"
                                  : data["lastMessage"],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black54
                                    : Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                    
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            timeText,
                            style: TextStyle(
                              color: isLight
                                  ? Colors.black45
                                  : Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (unread > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                unread.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _UserName extends StatelessWidget {
  final String userId;
  final bool isLight;

  const _UserName({
    required this.userId,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text(
            "Loading...",
            style: TextStyle(
              color: isLight ? Colors.black : Colors.white,
            ),
          );
        }

        final data =
            snapshot.data!.data() as Map<String, dynamic>?;

        return Text(
          data?["firstname"] ?? "User",
          style: TextStyle(
            color: isLight ? Colors.black : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}


String _formatTime(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);

  if (diff.inMinutes < 1) return "now";
  if (diff.inMinutes < 60) return "${diff.inMinutes}m";
  if (diff.inHours < 24) return "${diff.inHours}h";
  return "${time.day}/${time.month}";
}
