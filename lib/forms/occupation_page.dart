

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillshare_hub/controllers/provider/onboarding_provider/onboarding_controller.dart';

class OccupationPage extends ConsumerWidget {
  const OccupationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(onboardingControllerProvider.notifier);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60),
            Text("Occupation & Experience",
                style: TextStyle(color: Colors.white, fontSize: 28)),
      
            SizedBox(height: 20),
            Text("Occupation", style: TextStyle(color: Colors.white70)),
            _field("e.g., Developer, Designer", c.setOccupation),
      
            SizedBox(height: 20),
            Text("Experience", style: TextStyle(color: Colors.white70)),
            _field("Years of experience", c.setExperience),
      
            SizedBox(height: 20),
            Text("Bio", style: TextStyle(color: Colors.white70)),
            TextField(
              onChanged: c.setBio,
              maxLines: 4,
              style: TextStyle(color: Colors.white),
              decoration: _inputDecor("Short bio…"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String hint, Function(String) onChange) {
    return TextField(
      onChanged: onChange,
      style: TextStyle(color: Colors.white),
      decoration: _inputDecor(hint),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Color.fromARGB(255, 60, 64, 93),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.all(15),
    );
  }
}
