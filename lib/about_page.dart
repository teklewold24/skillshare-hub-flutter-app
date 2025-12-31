import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: isLight
          ? const Color(0xFFF4F5F7)
          : const Color.fromARGB(255, 42, 46, 76),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.school,
                    size: 80,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "SkillShare Hub",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isLight ? Colors.black : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(
                      color: isLight ? Colors.black54 : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "Application Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isLight ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "SkillShare Hub is a mobile application developed using Flutter "
              "and Firebase. It provides features such as user authentication, "
              "profile management, posting content, and real-time messaging.",
              style: TextStyle(
                color: isLight ? Colors.black87 : Colors.white70,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Developed Using",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isLight ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "• Flutter & Dart\n"
              "• Firebase Authentication\n"
              "• Cloud Firestore\n"
              "• Firebase Storage\n"
              "• Riverpod State Management",
              style: TextStyle(
                color: isLight ? Colors.black87 : Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
