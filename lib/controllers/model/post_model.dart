import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String uid;
  final String description;
  final String imageUrl;
  final String videoUrl;
  final int likes;
  final List<String> likedBy;
  final int commentCount;
  final Timestamp? timestamp;

  const PostModel({
    this.id = "",
    this.uid = "",
    this.description = "",
    this.imageUrl = "",
    this.videoUrl = "",
    this.likes = 0,
    this.likedBy = const [],
    this.commentCount = 0,
    this.timestamp,
  });

  PostModel copyWith({
    String? id,
    String? uid,
    String? description,
    String? imageUrl,
    String? videoUrl,
    int? likes,
    List<String>? likedBy,
    int? commentCount,
    Timestamp? timestamp,
  }) {
    return PostModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      commentCount: commentCount ?? this.commentCount,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "uid": uid,
      "description": description,
      "imageUrl": imageUrl,
      "videoUrl": videoUrl,
      "likes": likes,
      "likedBy": likedBy,
      "commentCount": commentCount,
      "timestamp": timestamp ?? FieldValue.serverTimestamp(),
    };
  }
}

