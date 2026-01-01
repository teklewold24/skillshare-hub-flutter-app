import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../model/task_model.dart';

part 'task_controller.g.dart';

@riverpod
class TaskController extends _$TaskController {
  @override
  TaskModel build() {
    ref.keepAlive();
    return const TaskModel();
  }

  void setTitle(String v) => state = state.copyWith(title: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setSkill(String v) => state = state.copyWith(skill: v);
  void setDuration(String v) => state = state.copyWith(duration: v);
  void setYoutubeUrl(String v) => state = state.copyWith(resourceUrl: v);

  void reset() => state = const TaskModel();

  Future<void> acceptTask(String taskId, String creatorUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not logged in");

    if (user.uid == creatorUid) {
      throw Exception("You cannot accept your own task");
    }

    final firestore = FirebaseFirestore.instance;
    final taskRef = firestore.collection("tasks").doc(taskId);

    await firestore.runTransaction((tx) async {
      final taskSnap = await tx.get(taskRef);
      if (!taskSnap.exists) return;

      final data = taskSnap.data() as Map<String, dynamic>;

      final List acceptedBy = List.from(data["acceptedBy"] ?? []);
      final int currentCount = data["acceptCount"] ?? 0;

      if (acceptedBy.contains(user.uid)) {
        throw Exception("You already accepted this task");
      }

      tx.update(taskRef, {
        "acceptedBy": FieldValue.arrayUnion([user.uid]),
        "acceptCount": currentCount + 1,
      });
    });

    final chatId = await createOrGetChat(
      creatorUid: creatorUid,
      accepterUid: user.uid,
    );

    await FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .add({
          "senderId": "system",
          "type": "task",
          "taskId": taskId,
          "text": "Accepted your task 🎉",
          "createdAt": FieldValue.serverTimestamp(),
        });
    await FirebaseFirestore.instance.collection("chats").doc(chatId).update({
      "lastMessage": "Accepted your task 🎉",
      "lastMessageAt": FieldValue.serverTimestamp(),
      "unread.$creatorUid": FieldValue.increment(1),
    });

    final accepterDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final accepterName = accepterDoc.data()?["firstname"] ?? "Someone";

    await _createTaskAcceptedNotification(
      receiverUid: creatorUid,
      senderUid: user.uid,
      taskId: taskId,
      senderName: accepterName,
    );
  }

  Future<String> createOrGetChat({
    required String creatorUid,
    required String accepterUid,
  }) async {
    final firestore = FirebaseFirestore.instance;

    final existingChats = await firestore
        .collection("chats")
        .where("users", arrayContains: creatorUid)
        .get();

    for (final doc in existingChats.docs) {
      final users = List<String>.from(doc["users"]);
      if (users.contains(accepterUid)) {
        return doc.id;
      }
    }

    final chatRef = await firestore.collection("chats").add({
      "users": [creatorUid, accepterUid],
      "lastMessage": "",
      "lastMessageAt": Timestamp.now(),
      "createdAt": Timestamp.now(),
      "unread": {creatorUid: 0, accepterUid: 0},
    });

    return chatRef.id;
  }

  Future<void> _createTaskAcceptedNotification({
    required String receiverUid,
    required String senderUid,
    required String taskId,
    required String senderName,
  }) async {
    final firestore = FirebaseFirestore.instance;

    await firestore
        .collection("users")
        .doc(receiverUid)
        .collection("notifications")
        .add({
          "type": "task_accepted",
          "title": "Task Accepted 🎉",
          "body": "$senderName accepted your task",
          "senderId": senderUid,
          "taskId": taskId,
          "isRead": false,
          "createdAt": FieldValue.serverTimestamp(),
        });
  }

  Future<void> createTask() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final userName = userDoc.data()?['firstname'] ?? "Unknown";

    await FirebaseFirestore.instance.collection("tasks").add({
      "uid": user.uid,
      "userName": userName,
      "title": state.title.trim(),
      "description": state.description.trim(),
      "skill": state.skill,
      "duration": state.duration,
      "resourceType": "youtube",
      "resourceUrl": state.resourceUrl.trim(),
      "acceptedBy": [],
      "acceptCount": 0,
      "createdAt": FieldValue.serverTimestamp(),
    });

    reset();
  }
}
