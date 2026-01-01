import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillshare_hub/controllers/provider/onboarding_provider/onboarding_controller.dart';

class ProfilePhotoPage extends ConsumerWidget {
  const ProfilePhotoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 42, 46, 76),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),

            const Text(
              "Add Profile Photo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            GestureDetector(
              onTap: () async {
                
                const demoImage =
                    "https://i.pravatar.cc/300";

                controller.setPhotoUrl(demoImage);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Profile photo selected"),
                  ),
                );
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 60, 64, 93),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white70,
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Tap to upload",
              style: TextStyle(color: Colors.white70),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () async {
                await controller.saveToFirestore();
                Navigator.pop(context);
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}

