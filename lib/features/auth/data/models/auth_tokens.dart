class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: Duration(seconds: json['expires_in'] as int),
    );
  }

  final String accessToken;
  final String refreshToken;
  final Duration expiresIn;
}
