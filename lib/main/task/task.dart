import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillshare_hub/controllers/provider/task_provider/task_controller.dart';
import 'package:skillshare_hub/main/task/widget/task_create_sheet.dart';
import 'package:skillshare_hub/main/task/widget/youtube_player.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  final List<String> categories = const [
    "Popular",
    "Programming",
    "Design",
    "Music",
    "Tutoring",
    "Writing",
    "Art",
    "Language",
  ];

  String searchQuery = "";
  String selectedCategory = "Popular";

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    const darkBg = Color.fromARGB(255, 42, 46, 76);

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF4F5F7) : darkBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff4c5c9b),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => openCreateTaskSheet(context, ref),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : const Color.fromARGB(255, 60, 64, 93),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
                  style: TextStyle(color: isLight ? Colors.black : Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search skills, tasks, or people...",
                    hintStyle: TextStyle(color: isLight ? Colors.black45 : Colors.white60),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: isLight ? Colors.black45 : Colors.white60),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final selected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? (isLight ? Colors.black : Colors.white)
                              : (isLight ? Colors.grey.shade200 : Colors.white12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: selected
                                ? (isLight ? Colors.white : Colors.black)
                                : (isLight ? Colors.black : Colors.white),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Available Tasks",
                style: TextStyle(
                  color: isLight ? Colors.black : Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

            
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("tasks")
                      .orderBy("createdAt", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                    final docs = snapshot.data!.docs;

                    
                    final filteredDocs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final title = (data["title"] ?? "").toString().toLowerCase();
                      final skill = (data["skill"] ?? "").toString().toLowerCase();
                      final user = (data["userName"] ?? "").toString().toLowerCase();

                      final matchesSearch = searchQuery.isEmpty ||
                          title.contains(searchQuery) ||
                          skill.contains(searchQuery) ||
                          user.contains(searchQuery);

                      final matchesCategory =
                          selectedCategory == "Popular" || skill == selectedCategory.toLowerCase();

                      return matchesSearch && matchesCategory;
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return Center(
                        child: Text(
                          "No matching tasks",
                          style: TextStyle(color: isLight ? Colors.black54 : Colors.white60),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await FirebaseFirestore.instance.collection("tasks").get();
                      },
                      child: ListView.builder(
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final data = filteredDocs[index].data() as Map<String, dynamic>;
                          final docId = filteredDocs[index].id;
                          return _taskCard(
                            isLight: isLight,
                            taskId: docId,
                            creatorUid: data["uid"] ?? "",
                            acceptedBy: List.from(data["acceptedBy"] ?? []),
                            user: data["userName"] ?? "Unknown",
                            time: _formatTime(data["createdAt"]),
                            title: data["title"] ?? "",
                            skill: data["skill"] ?? "",
                            duration: data["duration"] ?? "",
                            resourceType: data["resourceType"] ?? "none",
                            resourceUrl: data["resourceUrl"] ?? "",
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _taskCard({
    required bool isLight,
    required String taskId,
    required String creatorUid,
    required List acceptedBy,
    required String user,
    required String time,
    required String title,
    required String skill,
    required String duration,
    required String resourceType,
    required String resourceUrl,
  }) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser?.uid == creatorUid;
    final isAccepted = acceptedBy.contains(currentUser?.uid);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color.fromARGB(255, 60, 64, 93),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isLight ? Colors.grey.shade300 : Colors.white24,
                child: Icon(Icons.person, color: isLight ? Colors.black54 : Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user, style: TextStyle(color: isLight ? Colors.black : Colors.white, fontSize: 16)),
                    Text(time, style: TextStyle(color: isLight ? Colors.black45 : Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(taskId),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Text(title, style: TextStyle(color: isLight ? Colors.black : Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text("Skill: $skill", style: TextStyle(color: isLight ? Colors.black54 : Colors.white70)),
          Text("Duration: $duration", style: TextStyle(color: isLight ? Colors.black54 : Colors.white70)),
          if (resourceType == "youtube" && resourceUrl.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => TaskYoutubePlayer(youtubeUrl: resourceUrl)));
              },
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.play_arrow, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Watch Learning Video", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 15),
          if (!isOwner)
            ElevatedButton(
              onPressed: isAccepted
                  ? null
                  : () async {
                      try {
                        await ref.read(taskControllerProvider.notifier).acceptTask(taskId, creatorUid);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to accept task: $e")),
                        );
                      }
                    },
              child: Text(isAccepted ? "Already Accepted" : "Accept Task"),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(String taskId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection("tasks").doc(taskId).delete();
                Navigator.pop(context);
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inMinutes < 1) return "now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    return "${diff.inDays}d";
  }
}
