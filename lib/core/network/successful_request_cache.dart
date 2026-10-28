/// Shares concurrent loads and keeps successful values for a bounded time.
/// Failed loads are never cached and can be retried immediately.
class SuccessfulRequestCache<K, V> {
  SuccessfulRequestCache({required this.ttl, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final Duration ttl;
  final DateTime Function() _clock;
  final Map<K, _CacheEntry<V>> _values = {};
  final Map<K, Future<V>> _inFlight = {};
  final Map<K, int> _keyVersions = {};
  int _epoch = 0;

  Future<V> get(K key, Future<V> Function() load, {bool refresh = false}) {
    final pending = _inFlight[key];
    if (pending != null) return pending;

    final cached = _values[key];
    if (!refresh && cached != null && _clock().isBefore(cached.expiresAt)) {
      return Future.value(cached.value);
    }
    if (cached != null && !_clock().isBefore(cached.expiresAt)) {
      _values.remove(key);
    }

    final epoch = _epoch;
    final keyVersion = _keyVersions[key] ?? 0;
    late final Future<V> request;
    request = Future<V>.sync(load)
        .then((value) {
          if (epoch == _epoch && keyVersion == (_keyVersions[key] ?? 0)) {
            _values[key] = _CacheEntry(value, _clock().add(ttl));
          }
          return value;
        })
        .whenComplete(() {
          if (identical(_inFlight[key], request)) _inFlight.remove(key);
        });
    _inFlight[key] = request;
    return request;
  }

  void invalidate([K? key]) {
    if (key == null) {
      _values.clear();
      _inFlight.clear();
      _epoch++;
    } else {
      _values.remove(key);
      _inFlight.remove(key);
      _keyVersions[key] = (_keyVersions[key] ?? 0) + 1;
    }
  }

  int get inFlightCount => _inFlight.length;
  int get cachedCount => _values.length;
}

class _CacheEntry<V> {
  const _CacheEntry(this.value, this.expiresAt);
  final V value;
  final DateTime expiresAt;
}
