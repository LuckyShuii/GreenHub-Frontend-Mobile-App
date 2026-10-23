class ChangePasswordRequest {
  const ChangePasswordRequest({required this.newPassword});

  final String newPassword;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'new_password': newPassword,
  };
}
