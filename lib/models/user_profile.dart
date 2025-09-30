class UserProfile {
  final String name;
  final int age;
  final String email;
  final String role;
  final String avatar;
  final String organization;

  const UserProfile({
    required this.name,
    required this.age,
    required this.email,
    required this.role,
    required this.avatar,
    required this.organization,
  });

  // Default user profile for Mansi
  static const UserProfile defaultUser = UserProfile(
    name: 'Mansi Bhandari',
    age: 19,
    email: 'maxxxxxxxx23@gmail.com',
    role: 'Energy Management Specialist',
    avatar: 'MB', // Initials for avatar
    organization: 'Grevo Energy Solutions',
  );

  String get displayName => name;
  String get maskedEmail => email;
  String get initials {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return names[0].substring(0, 2).toUpperCase();
  }
}