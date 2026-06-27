/// Mirrors the `User` type from src/types/index.ts
class AppUser {
  final String uid;
  final String username;
  final String email;
  final bool isAdmin;
  final String? photoURL;

  AppUser({
    required this.uid,
    required this.username,
    required this.email,
    required this.isAdmin,
    this.photoURL,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      photoURL: map['photoURL'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'isAdmin': isAdmin,
      'photoURL': photoURL,
    };
  }
}
