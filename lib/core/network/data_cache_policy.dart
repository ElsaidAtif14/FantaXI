/// Initial in-memory freshness policy for FPL API resources.
class DataCachePolicy {
  DataCachePolicy._();

  static const bootstrapTtl = Duration(minutes: 5);
  static const managerTtl = Duration(seconds: 30);
  static const picksTtl = Duration(seconds: 20);
}
