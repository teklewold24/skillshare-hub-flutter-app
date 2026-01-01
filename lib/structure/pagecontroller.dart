import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:skillshare_hub/controllers/provider/onboarding_provider/onboarding_controller.dart'; 
import 'package:skillshare_hub/forms/occupation_page.dart'; 
import 'package:skillshare_hub/forms/personal_details.dart'; 
import 'package:skillshare_hub/forms/picture_upload.dart'; 
import 'package:skillshare_hub/forms/skills.dart';

class Pagecontroller extends ConsumerStatefulWidget {
  const Pagecontroller({super.key});

  @override
  ConsumerState<Pagecontroller> createState() =>
      _PagecontrollerState();
}


class _PagecontrollerState extends ConsumerState<Pagecontroller> {
  final PageController _controller = PageController();

  int currentPage = 0;
  final int totalPages = 4;

  void nextPage() {
    if (currentPage < totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      finish();
    }
  }

 Future<void> finish() async {
  
    await ref
        .read(onboardingControllerProvider.notifier)
        .saveToFirestore();

    if (!mounted) return;

    
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    

    final state = ref.read(onboardingControllerProvider);
    print('Onboarding complete for: ${state.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 42, 46, 76),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => currentPage = i),
                children: const [
                  PersonalDetails(),
                  OccupationPage(),
                  SkillsOfferedPage(),
                  ProfilePhotoPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: currentPage == 0
                        ? null
                        : () => _controller.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: List.generate(
                      totalPages,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: currentPage == i ? 12 : 8,
                        height: currentPage == i ? 12 : 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: currentPage == i
                              ? Colors.white
                              : Colors.white54,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  currentPage == totalPages - 1
                      ? ElevatedButton(
                          onPressed: finish,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Finish',
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                      : IconButton(
                          onPressed: nextPage,
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
