class UserModel {
  final String id;
  final String? name;
  final String? email;
  final String? photoUrl;
  final String? gender;
  final int? age;
  final String? skinType;
  final String? hairType;
  final List<String> concerns;
  final List<String> goals;
  final int? skinScore;
  final bool onboardingComplete;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    this.name,
    this.email,
    this.photoUrl,
    this.gender,
    this.age,
    this.skinType,
    this.hairType,
    this.concerns = const [],
    this.goals = const [],
    this.skinScore,
    this.onboardingComplete = false,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String?,
      email: map['email'] as String?,
      photoUrl: map['photoUrl'] as String?,
      gender: map['gender'] as String?,
      age: map['age'] as int?,
      skinType: map['skinType'] as String?,
      hairType: map['hairType'] as String?,
      concerns: List<String>.from(map['concerns'] ?? []),
      goals: List<String>.from(map['goals'] ?? []),
      skinScore: map['skinScore'] as int?,
      onboardingComplete: map['onboardingComplete'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'gender': gender,
      'age': age,
      'skinType': skinType,
      'hairType': hairType,
      'concerns': concerns,
      'goals': goals,
      'skinScore': skinScore,
      'onboardingComplete': onboardingComplete,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? gender,
    int? age,
    String? skinType,
    String? hairType,
    List<String>? concerns,
    List<String>? goals,
    int? skinScore,
    bool? onboardingComplete,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      skinType: skinType ?? this.skinType,
      hairType: hairType ?? this.hairType,
      concerns: concerns ?? this.concerns,
      goals: goals ?? this.goals,
      skinScore: skinScore ?? this.skinScore,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      createdAt: createdAt,
    );
  }
}
