enum AppEnvironment { development, production }

class AppConfig {
  AppConfig._();

  static const String _environmentName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const AppEnvironment environment =
      _environmentName == 'production'
          ? AppEnvironment.production
          : AppEnvironment.development;

  static bool get isDevelopment => environment == AppEnvironment.development;

  static bool get isProduction => environment == AppEnvironment.production;
}
