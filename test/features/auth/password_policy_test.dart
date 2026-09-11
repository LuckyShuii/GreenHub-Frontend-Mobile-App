import 'package:flutter_frontend/features/auth/utils/password_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasswordPolicy', () {
    test('accepts a password matching every requirement', () {
      expect(PasswordPolicy('Abcdefghij1!').isValid, isTrue);
    });

    test('rejects a password shorter than 12 characters', () {
      expect(PasswordPolicy('Abcdefg1!').hasMinimumLength, isFalse);
    });

    test('checks uppercase, lowercase, digit and special characters', () {
      expect(PasswordPolicy('abcdefghij1!').hasUppercase, isFalse);
      expect(PasswordPolicy('ABCDEFGHIJ1!').hasLowercase, isFalse);
      expect(PasswordPolicy('Abcdefghijk!').hasDigit, isFalse);
      expect(PasswordPolicy('Abcdefghijk1').hasSpecialCharacter, isFalse);
    });

    test('accepts backslash as an ASCII special character', () {
      expect(PasswordPolicy(r'Abcdefghij1\').hasSpecialCharacter, isTrue);
    });

    test('does not accept spaces as special characters', () {
      expect(PasswordPolicy('Abcdefghij1 ').hasSpecialCharacter, isFalse);
    });
  });
}
