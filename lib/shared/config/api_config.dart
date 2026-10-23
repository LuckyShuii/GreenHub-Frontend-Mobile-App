/// URL de base de l'API back-end.
///
/// Surchargeable au lancement avec :
/// `flutter run --dart-define=API_BASE_URL=http://<ip-ou-host>:8000`
///
/// Sans cette surcharge, utilise l'alias réseau spécial à l'émulateur
/// Android — ne fonctionne ni sur un iPhone physique, ni sur le web.
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
