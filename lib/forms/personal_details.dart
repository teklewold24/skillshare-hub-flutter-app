import 'package:flutter/material.dart';


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillshare_hub/controllers/provider/onboarding_provider/onboarding_controller.dart';

class PersonalDetails extends ConsumerWidget {
  const PersonalDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            "Personal Details",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          TextField(
            onChanged: (v) => ref.read(onboardingControllerProvider.notifier).setDateOfBirth(v),
            decoration: input("YYYY-MM-DD"),
          ),

          const SizedBox(height: 15),

          TextField(
            onChanged: (v) => ref.read(onboardingControllerProvider.notifier).setGender(v),
            decoration: input("Gender"),
          ),

          const SizedBox(height: 15),

          TextField(
            onChanged: (v) => ref.read(onboardingControllerProvider.notifier).setLocation(v),
            decoration: input("City / Country"),
          ),
        ],
      ),
    );
  }

  InputDecoration input(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Color.fromARGB(255, 60, 64, 93),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      );
}
