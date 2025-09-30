class User {
  final int id;
  final String name;
  final String avatar;

  User({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final nameData = json['name'] as Map<String, dynamic>;
    final fullName = '${nameData['first']} ${nameData['last']}';

    final pictureData = json['picture'] as Map<String, dynamic>;
    final avatarUrl = pictureData['medium'] as String;

    // Extract ID from UUID or use a hash-based ID if no numeric ID
    final loginData = json['login'] as Map<String, dynamic>?;
    final uuid = loginData?['uuid'] as String? ?? '';
    final numericId = uuid.hashCode.abs() % 10000 + 1; // Generate a pseudo-ID

    return User(
      id: numericId,
      name: fullName,
      avatar: avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
  };
}