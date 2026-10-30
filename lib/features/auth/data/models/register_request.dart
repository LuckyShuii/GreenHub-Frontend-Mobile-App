class RegisterRequest {
  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.postalCode,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String? postalCode;
  final String password;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'prenom': firstName.trim(),
      'nom': lastName.trim(),
      'email': email.trim().toLowerCase(),
      'pseudonyme': username.trim(),
      'code_postal': postalCode?.trim().isEmpty ?? true
          ? null
          : postalCode!.trim(),
      'mot_de_passe': password,
    };
  }
}
