import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

@riverpod
class SettingsController extends _$SettingsController {
  @override
  Map<String, dynamic> build() {
    _loadSettings();
    return {
      "darkMode": true,
      "notifications": true,
    };
  }

  Future<void> _loadSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    state = {
      "darkMode": doc["darkMode"] ?? true,
      "notifications": doc["notifications"] ?? true,
    };
  }

  Future<void> toggleDarkMode(bool value) async {
    state = {...state, "darkMode": value};
    _save("darkMode", value);
  }

  Future<void> toggleNotifications(bool value) async {
    state = {...state, "notifications": value};
    _save("notifications", value);
  }

  Future<void> _save(String key, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set({key: value}, SetOptions(merge: true));
  }
}
