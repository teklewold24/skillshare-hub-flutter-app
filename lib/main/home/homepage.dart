import 'package:flutter/material.dart';
import 'package:skillshare_hub/main/home/notifications_page.dart';
import 'package:skillshare_hub/main/home/widget/postcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillshare_hub/main/common/navigation.dart';

// TODO: Refactor HomePage animations later"
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    const darkBg = Color.fromARGB(255, 42, 46, 76);

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF4F5F7) : darkBg,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      size: 30,
                      color: isLight ? Colors.black : Colors.white,
                    ),
                    onPressed: () {
                      NavigationShell.scaffoldKey.currentState?.openDrawer();
                    },
                  ),

                  Text(
                    "SkillShare Hub",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isLight ? Colors.black : Colors.white,
                    ),
                  ),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection("notifications")
                        .where("isRead", isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final unreadCount = snapshot.data?.docs.length ?? 0;

                      return Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications,
                              size: 30,
                              color: isLight ? Colors.black : Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationPage(),
                                ),
                              );
                            },
                          ),

                          if (unreadCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount > 9
                                      ? "9+"
                                      : unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const WelcomeSection(),
              const SizedBox(height: 30),

              Text(
                "Recommended Tasks",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isLight ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(height: 15),

              SizedBox(
                height: 270,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("tasks")
                      .orderBy("createdAt", descending: true)
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No tasks available",
                          style: TextStyle(
                            color: isLight ? Colors.black54 : Colors.white70,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final data =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;

                        final acceptCount =
                            (data["acceptedBy"] as List?)?.length ?? 0;

                        return _RecommendedTaskCard(
                          title: data["title"] ?? "",
                          skill: data["skill"] ?? "",
                          duration: data["duration"] ?? "",
                          acceptCount: acceptCount,
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Recent Posts",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isLight ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(height: 15),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("posts")
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "No posts yet",
                        style: TextStyle(
                          color: isLight ? Colors.black54 : Colors.white70,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Postcard(
                          postId: doc.id,
                          name: data["userName"] ?? "Unknown",
                          detail: data["description"] ?? "",
                          time: _formatTime(data["timestamp"]),
                          imageUrl: data["imageUrl"],
                          videoUrl: data["videoUrl"],
                          likedBy: List.from(data["likedBy"] ?? []),
                          commentCount: data["commentCount"] ?? 0,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
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

class _RecommendedTaskCard extends StatefulWidget {
  final String title;
  final String skill;
  final String duration;
  final int acceptCount;

  const _RecommendedTaskCard({
    required this.title,
    required this.skill,
    required this.duration,
    required this.acceptCount,
  });

  @override
  State<_RecommendedTaskCard> createState() => _RecommendedTaskCardState();
}

class _RecommendedTaskCardState extends State<_RecommendedTaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slide = Tween(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          width: 240,
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLight
                ? const Color(0xFFFDFDFD) // soft off-white
                : const Color.fromARGB(255, 60, 65, 100),
            borderRadius: BorderRadius.circular(18),
            border: isLight ? Border.all(color: Colors.grey.shade200) : null,
            boxShadow: [
              BoxShadow(
                color: isLight
                    ? Colors.black.withOpacity(0.08)
                    : Colors.black.withOpacity(0.26),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isLight ? Colors.grey.shade100 : Colors.white12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.skill,
                  style: TextStyle(
                    color: isLight ? Colors.black87 : Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isLight ? Colors.black87 : Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.duration,
                    style: TextStyle(
                      color: isLight ? Colors.black54 : Colors.white60,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: isLight ? Colors.black45 : Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.acceptCount.toString(),
                        style: TextStyle(
                          color: isLight ? Colors.black54 : Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    final isLight = Theme.of(context).brightness == Brightness.light;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 80);

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final name = data?["firstname"] ?? "there";

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isLight
                ? const Color(0xFFFDFDFD)
                : const Color.fromARGB(255, 60, 65, 100),
            borderRadius: BorderRadius.circular(18),
            border: isLight ? Border.all(color: Colors.grey.shade200) : null,
            boxShadow: [
              BoxShadow(
                color: isLight
                    ? Colors.black.withOpacity(0.08)
                    : Colors.black.withOpacity(0.26),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: isLight
                    ? Colors.grey.shade200
                    : Colors.white24,
                child: Icon(
                  Icons.person,
                  color: isLight ? Colors.black87 : Colors.white,
                ),
              ),

              const SizedBox(width: 14),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back, $name 👋",
                    style: TextStyle(
                      color: isLight ? Colors.black87 : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Ready to learn or share today?",
                    style: TextStyle(
                      color: isLight ? Colors.black54 : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
