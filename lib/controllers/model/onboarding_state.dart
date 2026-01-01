class OnboardingState {
  final String dateOfBirth;
  final String gender;
  final String location;
  final String occupation;
  final String experience;
  final String bio;
  final String skill;
  final String workLink;
  final String achievements;
  final String? profilePhotoUrl;

  const OnboardingState({
    this.dateOfBirth = "",
    this.gender = "",
    this.location = "",
    this.occupation = "",
    this.experience = "",
    this.bio = "",
    this.skill = "",
    this.workLink = "",
    this.achievements = "",
    this.profilePhotoUrl,
  });

  OnboardingState copyWith({
    String? dateOfBirth,
    String? gender,
    String? location,
    String? occupation,
    String? experience,
    String? bio,
    String? skill,
    String? workLink,
    String? achievements,
    String? profilePhotoUrl,
  }) {
    return OnboardingState(
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      occupation: occupation ?? this.occupation,
      experience: experience ?? this.experience,
      bio: bio ?? this.bio,
      skill: skill ?? this.skill,
      workLink: workLink ?? this.workLink,
      achievements: achievements ?? this.achievements,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}
