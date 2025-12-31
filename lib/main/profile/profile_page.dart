import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillshare_hub/main/profile/profile_edit.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBackground = Color.fromARGB(255, 42, 46, 76);
    final isLight = Theme.of(context).brightness == Brightness.light;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor:
            isLight ? const Color(0xFFF4F5F7) : darkBackground,
        body: const Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      backgroundColor:
          isLight ? const Color(0xFFF4F5F7) : darkBackground,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final data =
                snapshot.data!.data() as Map<String, dynamic>;

            final String firstname = data['firstname'] ?? 'User';
            final String bio = data['bio'] ?? 'No bio yet';
            final List skills = data['skills'] ?? [];
            final String link = data['workLink'] ?? '';
            final String? photoUrl =
                data['profilePhotoUrl'];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  Row(
                    children: [
                      Text(
                        'Profile',
                        style: TextStyle(
                          color: isLight
                              ? Colors.black
                              : Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: isLight
                              ? Colors.black
                              : Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const EditProfilePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                 
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: isLight
                              ? Colors.grey.shade300
                              : Colors.white24,
                          backgroundImage:
                              photoUrl != null &&
                                      photoUrl.isNotEmpty
                                  ? NetworkImage(photoUrl)
                                  : null,
                          child: photoUrl == null ||
                                  photoUrl.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 55,
                                  color: isLight
                                      ? Colors.black54
                                      : Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          firstname,
                          style: TextStyle(
                            color: isLight
                                ? Colors.black
                                : Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  
                  _SectionCard(
                    isLight: isLight,
                    title: 'About Me',
                    child: Text(
                      bio,
                      style: TextStyle(
                        color: isLight
                            ? Colors.black87
                            : Colors.white70,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                
                  _SectionCard(
                    isLight: isLight,
                    title: 'Skills Offered',
                    child: skills.isEmpty
                        ? Text(
                            'No skill added yet',
                            style: TextStyle(
                              color: isLight
                                  ? Colors.black54
                                  : Colors.white60,
                            ),
                          )
                        : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: skills.map<Widget>((skill) {
                              return Chip(
                                backgroundColor: isLight
                                    ? Colors.grey.shade200
                                    : Colors.white12,
                                label: Text(
                                  skill,
                                  style: TextStyle(
                                    color: isLight
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),

                  const SizedBox(height: 20),

                 
                  _SectionCard(
                    isLight: isLight,
                    title: 'Profile Link',
                    child: link.isEmpty
                        ? const Text("No link added yet")
                        : GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse(
                                link.startsWith('http')
                                    ? link
                                    : 'https://$link',
                              );
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode
                                      .externalApplication,
                                );
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.link,
                                    color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    link,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration:
                                          TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isLight;

  const _SectionCard({
    required this.title,
    required this.child,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight
            ? Colors.white
            : const Color.fromARGB(255, 60, 65, 100),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isLight ? Colors.black : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
