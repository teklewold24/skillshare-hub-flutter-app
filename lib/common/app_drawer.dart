import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillshare_hub/main/common/bookmark_page.dart';
import 'package:skillshare_hub/main/profile/profile_page.dart';
import 'package:skillshare_hub/services/settings_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Drawer(
     
      backgroundColor: isLight
          ? const Color(0xFFF4F5F7) 
          : const Color.fromARGB(255, 42, 46, 76),

      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isLight
                        ? Colors.grey.shade300
                        : Colors.white24,
                    child: Icon(
                      Icons.person,
                      color: isLight ? Colors.black : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? "Guest",
                        style: TextStyle(
                          color: isLight ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "SkillShare Hub",
                        style: TextStyle(
                          color: isLight ? Colors.black54 : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(color: isLight ? Colors.grey.shade300 : Colors.white24),

          
            _DrawerItem(
              icon: Icons.person,
              title: "Profile",
              isLight: isLight,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),

            _DrawerItem(
              icon: Icons.bookmark,
              title: "Bookmarks",
              isLight: isLight,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookmarkPage()),
                );
              },
            ),

            _DrawerItem(
              icon: Icons.settings,
              title: "Settings",
              isLight: isLight,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),

            const Spacer(),

            Divider(color: isLight ? Colors.grey.shade300 : Colors.white24),

           
            _DrawerItem(
              icon: Icons.logout,
              title: "Logout",
              isLight: isLight,
              color: Colors.redAccent,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  final bool isLight;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isLight,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? (isLight ? Colors.black87 : Colors.white),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? (isLight ? Colors.black87 : Colors.white),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
