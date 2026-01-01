import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      
      backgroundColor: isLight
          ? const Color(0xFFF4F5F7)
          : const Color.fromARGB(255, 42, 46, 76),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: isLight
            ? Colors.white
            : const Color.fromARGB(255, 42, 46, 76),
        foregroundColor: isLight ? Colors.black : Colors.white,
        title: const Text("Notifications"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .collection("notifications")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No notifications",
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

              return _NotificationCard(
                notificationId: doc.id,
                userId: user.uid,
                fromUserId: data["fromUserId"] ?? "",
                text: data["text"] ?? "",
                time: data["createdAt"],
                isRead: data["isRead"] ?? false,
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String notificationId;
  final String userId;
  final String fromUserId;
  final String text;
  final Timestamp? time;
  final bool isRead;

  const _NotificationCard({
    required this.notificationId,
    required this.userId,
    required this.fromUserId,
    required this.text,
    required this.time,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return GestureDetector(
      onTap: () async {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("notifications")
            .doc(notificationId)
            .update({"isRead": true});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
        
          color: isLight
              ? (isRead ? Colors.white : const Color(0xFFE8EBF1))
              : (isRead
                  ? const Color.fromARGB(255, 60, 65, 100)
                  : const Color.fromARGB(255, 80, 85, 140)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLight
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              Icons.notifications,
              color: isLight ? Colors.black54 : Colors.white,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _UserName(userId: fromUserId),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      color: isLight ? Colors.black87 : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatTime(time),
              style: TextStyle(
                color: isLight ? Colors.black45 : Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserName extends StatelessWidget {
  final String userId;
  const _UserName({required this.userId});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (userId.isEmpty) {
      return Text(
        "System",
        style: TextStyle(
          color: isLight ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text(
            "User",
            style: TextStyle(
              color: isLight ? Colors.black : Colors.white,
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        return Text(
          data["firstname"] ?? "User",
          style: TextStyle(
            color: isLight ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}

String _formatTime(Timestamp? timestamp) {
  if (timestamp == null) return "";
  final diff = DateTime.now().difference(timestamp.toDate());
  if (diff.inMinutes < 1) return "now";
  if (diff.inMinutes < 60) return "${diff.inMinutes}m";
  if (diff.inHours < 24) return "${diff.inHours}h";
  return "${diff.inDays}d";
}
