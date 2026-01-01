import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:skillshare_hub/controllers/model/onboarding_state.dart';


part 'onboarding_controller.g.dart';

@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  OnboardingState build() {
    ref.keepAlive();
    return const OnboardingState();
  }

  void setDateOfBirth(String v) => state = state.copyWith(dateOfBirth: v);
  void setGender(String v) => state = state.copyWith(gender: v);
  void setLocation(String v) => state = state.copyWith(location: v);
  void setOccupation(String v) => state = state.copyWith(occupation: v);
  void setExperience(String v) => state = state.copyWith(experience: v);
  void setBio(String v) => state = state.copyWith(bio: v);
  void setSkill(String v) => state = state.copyWith(skill: v);
  void setWorkLink(String v) => state = state.copyWith(workLink: v);
  void setAchievements(String v) => state = state.copyWith(achievements: v);
  void setPhotoUrl(String v) => state = state.copyWith(profilePhotoUrl: v);


Future<void> saveToFirestore() async {
  final user = FirebaseAuth.instance.currentUser!;
  
 
  List<String> skillsList = state.skill.isNotEmpty 
      ? state.skill.split(',').map((e) => e.trim()).toList() 
      : [];

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({
    'dateOfBirth': state.dateOfBirth,
    'gender': state.gender,
    'location': state.location,
    'occupation': state.occupation,
    'experience': state.experience,
    'bio': state.bio,
    'skills': skillsList, 
    'workLink': state.workLink,
    'achievements': state.achievements,
    'profilePhotoUrl': state.profilePhotoUrl,
    'profileCompleted': true,
  }, SetOptions(merge: true));
}
}
