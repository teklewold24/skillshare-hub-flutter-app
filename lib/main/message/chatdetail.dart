import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final String otherUserId;

  const ChatDetailPage({
    super.key,
    required this.chatId,
    required this.otherUserId,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || user == null) return;

    final text = _messageController.text.trim();
    _messageController.clear();

    final chatRef =
        FirebaseFirestore.instance.collection("chats").doc(widget.chatId);

    await chatRef.collection("messages").add({
      "senderId": user!.uid,
      "text": text,
      "createdAt": FieldValue.serverTimestamp(),
      "seenBy": [user!.uid],
    });

    await chatRef.update({
      "lastMessage": text,
      "lastMessageAt": FieldValue.serverTimestamp(),
      "unread.${widget.otherUserId}": FieldValue.increment(1),
      "unread.${user!.uid}": 0,
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.otherUserId)
        .collection("notifications")
        .add({
      "type": "message",
      "fromUserId": user!.uid,
      "chatId": widget.chatId,
      "text": "New message",
      "isRead": false,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  @override
  void initState() {
    super.initState();
    if (user != null) {
      FirebaseFirestore.instance
          .collection("chats")
          .doc(widget.chatId)
          .update({"unread.${user!.uid}": 0});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;


    final background = isLight
        ? const Color(0xFFF4F5F7)
        : const Color.fromARGB(255, 42, 46, 76);

    final myBubble = isLight
        ? Colors.blue.shade600
        : const Color.fromARGB(255, 98, 105, 160);

    final otherBubble = isLight
        ? Colors.white
        : const Color.fromARGB(255, 60, 65, 100);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isLight ? Colors.black : Colors.white,
        ),
        title: _ChatUserStatus(
          userId: widget.otherUserId,
          isLight: isLight,
        ),
      ),
      body: Column(
        children: [
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chats")
                  .doc(widget.chatId)
                  .collection("messages")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final msg = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                    final bool isMe = msg["senderId"] == user!.uid;
                    final bool isSeen =
                        (msg["seenBy"] as List?)?.contains(
                                widget.otherUserId) ??
                            false;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? myBubble : otherBubble,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: isLight && !isMe
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 6,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Text(
                              msg["text"] ?? "",
                              style: TextStyle(
                                color:
                                    isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),

                          if (isMe)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: AnimatedSwitcher(
                                duration:
                                    const Duration(milliseconds: 300),
                                child: Text(
                                  isSeen ? "Seen ✔✔" : "Sent ✔",
                                  key: ValueKey(isSeen),
                                  style: TextStyle(
                                    color: isLight
                                        ? Colors.black45
                                        : Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          
          SafeArea(
            top: false,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: background,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(
                        color: isLight ? Colors.black : Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(
                          color:
                              isLight ? Colors.black45 : Colors.white54,
                        ),
                        filled: true,
                        fillColor: isLight
                            ? Colors.white
                            : const Color.fromARGB(255, 60, 65, 100),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: isLight ? Colors.blue : Colors.white,
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ChatUserStatus extends StatelessWidget {
  final String userId;
  final bool isLight;

  const _ChatUserStatus({
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
            "Chat",
            style: TextStyle(
              color: isLight ? Colors.black : Colors.white,
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        final bool isOnline = data?["isOnline"] ?? false;
        final Timestamp? lastSeen = data?["lastSeen"];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data?["firstname"] ?? "User",
              style: TextStyle(
                color: isLight ? Colors.black : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isOnline
                  ? "Online"
                  : lastSeen == null
                      ? "Offline"
                      : "Last seen ${_formatLastSeen(lastSeen.toDate())}",
              style: TextStyle(
                color: isLight ? Colors.black45 : Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }
}

String _formatLastSeen(DateTime time) {
  final diff = DateTime.now().difference(time);

  if (diff.inMinutes < 1) return "just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
  if (diff.inHours < 24) return "${diff.inHours}h ago";
  return "${time.day}/${time.month}";
}
