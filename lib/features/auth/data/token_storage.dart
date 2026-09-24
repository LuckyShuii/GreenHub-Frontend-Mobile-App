import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenStorage {
  Future<String?> readRefreshToken();

  Future<void> writeRefreshToken(String refreshToken);

  Future<String?> readDeviceId();

  Future<void> writeDeviceId(String deviceId);

  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _refreshTokenKey = 'auth.refresh_token';
  static const String _deviceIdKey = 'auth.device_id';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  @override
  Future<void> writeRefreshToken(String refreshToken) {
    return _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<String?> readDeviceId() => _storage.read(key: _deviceIdKey);

  @override
  Future<void> writeDeviceId(String deviceId) {
    return _storage.write(key: _deviceIdKey, value: deviceId);
  }

  @override
  Future<void> clear() => _storage.delete(key: _refreshTokenKey);
}
