import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillshare_hub/controllers/provider/onboarding_provider/onboarding_controller.dart';



class SkillsOfferedPage extends ConsumerWidget {
  const SkillsOfferedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(onboardingControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 60),
          Text("Skills You Offer",
              style: TextStyle(color: Colors.white, fontSize: 28)),

          SizedBox(height: 20),
          Text("Skill", style: TextStyle(color: Colors.white70)),
          _field("e.g., Flutter, Guitar", c.setSkill),

          SizedBox(height: 20),
          Text("Work Link", style: TextStyle(color: Colors.white70)),
          _field("LinkedIn, Portfolio...", c.setWorkLink),

          SizedBox(height: 20),
          Text("Achievements", style: TextStyle(color: Colors.white70)),
          TextField(
            onChanged: c.setAchievements,
            maxLines: 4,
            style: TextStyle(color: Colors.white),
            decoration: _decor("List achievements…"),
          ),
        ],
      ),
    );
  }

  Widget _field(String hint, Function(String) onChange) {
    return TextField(
      onChanged: onChange,
      style: TextStyle(color: Colors.white),
      decoration: _decor(hint),
    );
  }

  InputDecoration _decor(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Color.fromARGB(255, 60, 64, 93),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.all(15),
      );
}
