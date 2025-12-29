import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillshare_hub/firebase_options.dart';
import 'package:skillshare_hub/main/home/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillshare_hub/navigation.dart';
import 'package:skillshare_hub/registration/landing.dart';
import 'package:skillshare_hub/structure/pagecontroller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          if (snap.hasData) {
            return const HomePage();
          }
          return const Landing();
        },
      ),
      routes: {
        '/onboard': (_) => const Pagecontroller(),
        '/navigation': (_) => const NavigationShell(),
      },
    );
  }
}
