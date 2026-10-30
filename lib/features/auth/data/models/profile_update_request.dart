class ProfileUpdateRequest {
  const ProfileUpdateRequest({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.postalCode,
  });

  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? postalCode;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'first_name': firstName.trim(),
    'last_name': lastName.trim(),
    'username': username.trim(),
    'email': email.trim().toLowerCase(),
    'postal_code': postalCode?.trim().isEmpty ?? true
        ? null
        : postalCode!.trim(),
  };
}
