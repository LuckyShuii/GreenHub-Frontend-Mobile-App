String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Veuillez renseigner votre adresse e-mail.';
  }
  if (!value.contains('@')) {
    return 'Veuillez saisir une adresse e-mail valide.';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Veuillez renseigner votre mot de passe.';
  }
  return null;
}

String? validateRequired(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Veuillez renseigner ce champ.';
  }
  return null;
}
