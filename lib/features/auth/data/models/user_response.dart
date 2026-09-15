class UserResponse {
  const UserResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.location,
    required this.createdAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as int,
      firstName: json['prenom'] as String,
      lastName: json['nom'] as String,
      email: json['email'] as String,
      username: json['pseudonyme'] as String,
      location: json['localisation'] as String?,
      createdAt: DateTime.parse(json['date_creation'] as String),
    );
  }

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String? location;
  final DateTime createdAt;
}
