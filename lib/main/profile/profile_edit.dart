import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();

  List<String> skills = [];
  final TextEditingController skillInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;
    setState(() {
      nameController.text = data["firstname"] ?? "";
      dobController.text = data["dateOfBirth"] ?? "";
      genderController.text = data["gender"] ?? "";
      locationController.text = data["location"] ?? "";
      occupationController.text = data["occupation"] ?? "";
      linkController.text = data["workLink"] ?? "";
      aboutController.text = data["bio"] ?? "";

      if (data["skills"] != null) {
    skills = List<String>.from(data["skills"]);
  } else if (data["skill"] != null && data["skill"].toString().isNotEmpty) {
    
    skills = [data["skill"]];
  }
    });
  }

 Future<void> _saveProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .set({
    "firstname": nameController.text.trim(),
    "dob": dobController.text.trim(),
    "gender": genderController.text.trim(),
    "location": locationController.text.trim(),
    "occupation": occupationController.text.trim(),
    "bio": aboutController.text.trim(),
    "workLink": linkController.text.trim(),

   
    "skills": skills, 
    "skill": skills.isNotEmpty ? skills.first : "", 

    "updatedAt": FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  if (mounted) {
    Navigator.pop(context);
  }
}


  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight
          ? const Color(0xFFF4F5F7)
          : const Color.fromARGB(255, 42, 46, 76),

      appBar: AppBar(
        iconTheme: IconThemeData(
          color: isLight ? Colors.black : Colors.white,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: isLight ? Colors.black : Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
             
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: isLight
                          ? Colors.grey.shade300
                          : Colors.white24,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: isLight ? Colors.black54 : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              _inputField("Full Name", nameController, isLight),
              _inputField("Date of Birth (YYYY-MM-DD)", dobController, isLight),
              _inputField("Gender", genderController, isLight),
              _inputField("Location (City, Country)", locationController, isLight),
              _inputField("Occupation", occupationController, isLight),
              _inputField("LinkedIn / Portfolio URL", linkController, isLight),

              const SizedBox(height: 20),

              _textArea("About Me", aboutController, isLight),

              const SizedBox(height: 25),

             
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Skills Offered",
                    style: TextStyle(
                      color: isLight ? Colors.black : Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: _addSkillDialog,
                    icon: Icon(
                      Icons.add,
                      color: isLight ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: skills.map((skill) {
                  return Chip(
                    label: Text(skill),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () {
                      setState(() => skills.remove(skill));
                    },
                    backgroundColor: isLight
                        ? Colors.grey.shade200
                        : Colors.white24,
                    labelStyle: TextStyle(
                      color: isLight ? Colors.black : Colors.white,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 35),

            
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    String hint,
    TextEditingController controller,
    bool isLight,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        style: TextStyle(color: isLight ? Colors.black : Colors.white),
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: TextStyle(
            color: isLight ? Colors.black54 : Colors.white70,
          ),
          filled: true,
          fillColor: isLight
              ? Colors.white
              : const Color.fromARGB(255, 60, 64, 93),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _textArea(
    String label,
    TextEditingController controller,
    bool isLight,
  ) {
    return TextField(
      controller: controller,
      maxLines: 4,
      style: TextStyle(color: isLight ? Colors.black : Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isLight ? Colors.black54 : Colors.white70,
        ),
        filled: true,
        fillColor: isLight
            ? Colors.white
            : const Color.fromARGB(255, 60, 64, 93),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _addSkillDialog() {
    final isLight = Theme.of(context).brightness == Brightness.light;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: isLight
              ? Colors.white
              : const Color.fromARGB(255, 60, 64, 93),
          title: Text(
            "Add Skill",
            style: TextStyle(
              color: isLight ? Colors.black : Colors.white,
            ),
          ),
          content: TextField(
            controller: skillInput,
            style: TextStyle(
              color: isLight ? Colors.black : Colors.white,
            ),
            decoration: InputDecoration(
              hintText: "E.g., Flutter, Guitar, Python",
              hintStyle: TextStyle(
                color: isLight ? Colors.black45 : Colors.white54,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                skillInput.clear();
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: isLight ? Colors.black54 : Colors.white70,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (skillInput.text.trim().isNotEmpty) {
                    skills.add(skillInput.text.trim());
                  }
                });
                skillInput.clear();
                Navigator.pop(context);
              },
              child: const Text(
                "Add",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }
}

