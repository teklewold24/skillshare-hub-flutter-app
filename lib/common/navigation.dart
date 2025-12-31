import 'package:flutter/material.dart';
import 'package:skillshare_hub/main/common/app_drawer.dart';
import 'package:skillshare_hub/main/home/homepage.dart';
import 'package:skillshare_hub/main/message/message_page.dart';
import 'package:skillshare_hub/main/posts/post_page.dart';
import 'package:skillshare_hub/main/profile/profile_page.dart';
import 'package:skillshare_hub/main/task/task.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _selectedIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    TasksPage(),
    PostPage(),
    MessagePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    const darkBg = Color.fromARGB(255, 42, 46, 76);

    return Scaffold(
      key: NavigationShell.scaffoldKey,

      backgroundColor: isLight ? const Color(0xFFF4F5F7) : darkBg,

      drawer: const AppDrawer(),

      body: pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isLight ? Colors.white : darkBg,
        selectedItemColor: isLight ? Colors.black : Colors.white,
        unselectedItemColor: isLight ? Colors.black54 : Colors.white54,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Post"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
