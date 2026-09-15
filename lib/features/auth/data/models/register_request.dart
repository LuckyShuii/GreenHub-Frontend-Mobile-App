class RegisterRequest {
  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.location,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String? location;
  final String password;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'prenom': firstName.trim(),
      'nom': lastName.trim(),
      'email': email.trim().toLowerCase(),
      'pseudonyme': username.trim(),
      'localisation': location?.trim().isEmpty ?? true
          ? null
          : location!.trim(),
      'mot_de_passe': password,
    };
  }
}
