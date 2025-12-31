import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

 
  Future<void> createChat(String otherUserId) async {
  final user = FirebaseAuth.instance.currentUser!;
  final chatRef = FirebaseFirestore.instance.collection("chats");

  final existing = await chatRef
      .where("users", arrayContains: user.uid)
      .get();

  for (final doc in existing.docs) {
    final users = List<String>.from(doc["users"]);
    if (users.contains(otherUserId)) return;
  }

  await chatRef.add({
    "users": [user.uid, otherUserId],
    "lastMessage": "",
    "lastMessageAt": FieldValue.serverTimestamp(),
    "createdAt": FieldValue.serverTimestamp(),
    "unread": {
      user.uid: 0,
      otherUserId: 0,
    },
  });
}



  Future<void> sendMessage(String chatId, String text) async {
    final userId = _auth.currentUser!.uid;

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': userId,
      'text': text,
      'createdAt': Timestamp.now(),
    });

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageAt': Timestamp.now(),
    });
  }
}
