import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skillshare_hub/controllers/provider/post_provider/postcontroller.dart';

class PostPage extends ConsumerStatefulWidget {
  const PostPage({super.key});

  @override
  ConsumerState<PostPage> createState() => _PostPageState();
}

class _PostPageState extends ConsumerState<PostPage> {
  File? selectedMedia;
  bool isVideo = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        selectedMedia = File(file.path);
        isVideo = false;
      });
    }
  }

  Future<void> pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        selectedMedia = File(file.path);
        isVideo = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    // scoffold
    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF4F5F7) : Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "New Post",
                style: TextStyle(
                  color: isLight ? Colors.black : Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Description",
                style: TextStyle(
                  color: isLight ? Colors.black54 : Colors.white60,
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                maxLines: 6,
                style: TextStyle(color: isLight ? Colors.black : Colors.white),
                onChanged: (v) {
                  ref.read(postcontrollerProvider.notifier).setDescription(v);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isLight ? Colors.white : Colors.white12,
                  hintText: "Write something...",
                  hintStyle: TextStyle(
                    color: isLight ? Colors.black45 : Colors.white30,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Add Image"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLight ? Colors.white : Colors.white24,
                      foregroundColor: isLight ? Colors.black : Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: pickVideo,
                    icon: const Icon(Icons.videocam),
                    label: const Text("Add Video"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLight ? Colors.white : Colors.white24,
                      foregroundColor: isLight ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (selectedMedia != null)
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isLight
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                  child: isVideo
                      ? Center(
                          child: Icon(
                            Icons.videocam,
                            size: 80,
                            color: isLight ? Colors.black54 : Colors.white,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(selectedMedia!, fit: BoxFit.cover),
                        ),
                ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(postcontrollerProvider.notifier)
                        .saveToFirestore(selectedMedia, isVideo);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Post Published!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4c5c9b),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Publish Post",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
