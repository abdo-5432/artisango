class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String photoUrl;
  final String city;
  final String bio;
  final String phoneNumber; // <-- add this
  final List<String> favorites;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.photoUrl,
    required this.city,
    required this.bio,
    required this.phoneNumber, // <-- add
    this.favorites = const [],
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'client',
      photoUrl: map['photoUrl'] ?? '',
      city: map['city'] ?? '',
      bio: map['bio'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '', // <-- add
      favorites: List<String>.from(map['favorites'] ?? []),
    );
  }
}
