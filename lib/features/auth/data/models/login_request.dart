class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
    this.deviceInfo,
  });

  final String email;
  final String password;
  final String? deviceInfo;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> payload = <String, dynamic>{
      'email': email.trim().toLowerCase(),
      'mot_de_passe': password,
    };
    if (deviceInfo != null) {
      payload['device_info'] = deviceInfo;
    }
    return payload;
  }
}
