import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillshare_hub/controllers/provider/task_provider/task_controller.dart';

void openCreateTaskSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CreateTaskSheet(),
  );
}

class _CreateTaskSheet extends ConsumerStatefulWidget {
  const _CreateTaskSheet();

  @override
  ConsumerState<_CreateTaskSheet> createState() =>
      _CreateTaskSheetState();
}

class _CreateTaskSheetState
    extends ConsumerState<_CreateTaskSheet> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.read(taskControllerProvider.notifier);
    final isLight =
        Theme.of(context).brightness == Brightness.light;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      expand: false,
      builder: (_, scroll) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isLight
                ? Colors.white
                : const Color(0xff21233c),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scroll,
            children: [
              _input(
                context,
                "Title",
                controller.setTitle,
              ),
              _input(
                context,
                "Description",
                controller.setDescription,
              ),
              _input(
                context,
                "Skill",
                controller.setSkill,
              ),
              _input(
                context,
                "Duration",
                controller.setDuration,
              ),

              const SizedBox(height: 12),

              _input(
                context,
                "YouTube Video URL",
                controller.setYoutubeUrl,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () async {
                  await controller.createTask();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4c5c9b),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Create Task",
                  style:
                      TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _input(
  BuildContext context,
  String hint,
  Function(String) onChanged,
) {
  final isLight =
      Theme.of(context).brightness == Brightness.light;

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      onChanged: onChanged,
      style: TextStyle(
        color: isLight ? Colors.black : Colors.white,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isLight ? Colors.black45 : Colors.white60,
        ),
        filled: true,
        fillColor: isLight
            ? Colors.grey.shade100
            : Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}
