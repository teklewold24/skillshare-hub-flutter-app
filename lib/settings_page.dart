import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillshare_hub/controllers/provider/settings/settings_controller.dart';
import 'package:skillshare_hub/services/about_page.dart';
import 'package:skillshare_hub/services/privacy_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          
          SwitchListTile(
            title: const Text("Dark Theme"),
            value: settings["darkMode"],
            onChanged: (val) {
              ref
                  .read(settingsControllerProvider.notifier)
                  .toggleDarkMode(val);
            },
          ),

          const Divider(),

         
          SwitchListTile(
            title: const Text("Notifications"),
            value: settings["notifications"],
            onChanged: (val) {
              ref
                  .read(settingsControllerProvider.notifier)
                  .toggleNotifications(val);
            },
          ),

          const Divider(),

         ListTile(
  title: const Text("Privacy"),
  trailing: const Icon(Icons.arrow_forward_ios),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyPage()),
    );
  },
),

ListTile(
  title: const Text("About"),
  trailing: const Icon(Icons.arrow_forward_ios),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutPage()),
    );
  },
),

        ],
      ),
    );
  }
}
