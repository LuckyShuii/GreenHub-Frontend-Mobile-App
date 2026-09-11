class PasswordPolicy {
  const PasswordPolicy(this.password);

  final String password;

  bool get hasMinimumLength => password.runes.length >= 12;
  bool get hasUppercase => password.contains(RegExp('[A-Z]'));
  bool get hasLowercase => password.contains(RegExp('[a-z]'));
  bool get hasDigit => password.contains(RegExp('[0-9]'));
  bool get hasSpecialCharacter => password.runes.any(
    (int character) =>
        (character >= 33 && character <= 47) ||
        (character >= 58 && character <= 64) ||
        (character >= 91 && character <= 96) ||
        (character >= 123 && character <= 126),
  );

  bool get isValid =>
      hasMinimumLength &&
      hasUppercase &&
      hasLowercase &&
      hasDigit &&
      hasSpecialCharacter;
}
