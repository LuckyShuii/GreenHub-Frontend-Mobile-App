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

String? validatePostalCode(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  if (!RegExp(r'^\d{5}$').hasMatch(value)) {
    return 'Le code postal doit contenir 5 chiffres.';
  }
  return null;
}

String? validateUsername(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Veuillez renseigner votre pseudonyme.';
  }
  if (value.trim().runes.length > 50) {
    return 'Le pseudonyme ne doit pas dépasser 50 caractères.';
  }
  return null;
}
