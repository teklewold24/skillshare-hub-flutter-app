import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

@riverpod
class SettingsController extends _$SettingsController {
  final _messaging = FirebaseMessaging.instance;

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

    final enabled = doc.data()?["notifications"] ?? true;

    state = {
      "darkMode": doc.data()?["darkMode"] ?? true,
      "notifications": enabled,
    };

   
    if (enabled) {
      await _enableNotifications();
    } else {
      await _disableNotifications();
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    state = {...state, "darkMode": value};
    await _save("darkMode", value);
  }


  Future<void> toggleNotifications(bool value) async {
    state = {...state, "notifications": value};

    if (value) {
      await _enableNotifications();
    } else {
      await _disableNotifications();
    }

    await _save("notifications", value);
  }

  Future<void> _enableNotifications() async {
    await _messaging.requestPermission();
    await _messaging.subscribeToTopic("all_users");
  }

  Future<void> _disableNotifications() async {
    await _messaging.unsubscribeFromTopic("all_users");
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
