import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: isLight
          ? const Color(0xFFF4F5F7)
          : const Color.fromARGB(255, 42, 46, 76),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("User Privacy", isLight),
              _sectionText(
                "We respect your privacy. All user data is securely stored "
                "using Firebase services and is never shared with third parties.",
                isLight,
              ),

              _sectionTitle("Data Collection", isLight),
              _sectionText(
                "The application collects only the information required to "
                "provide its features such as authentication, messaging, and "
                "profile management.",
                isLight,
              ),

              _sectionTitle("Data Security", isLight),
              _sectionText(
                "All data is protected using Firebase Authentication, "
                "Firestore security rules, and secure cloud storage.",
                isLight,
              ),

              _sectionTitle("User Control", isLight),
              _sectionText(
                "Users can edit or update their profile information at any time "
                "from the profile edit page.",
                isLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, bool isLight) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isLight ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  Widget _sectionText(String text, bool isLight) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: isLight ? Colors.black87 : Colors.white70,
        height: 1.5,
      ),
    );
  }
}
