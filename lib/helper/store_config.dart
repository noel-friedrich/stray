// from https://www.revenuecat.com/blog/engineering/flutter-subscriptions-tutorial/

enum Store { appleStore, googlePlay }

class StoreConfig {
  final Store store;
  final String apiKey;
  static StoreConfig? _instance;

  factory StoreConfig({required Store store, required String apiKey}) {
    _instance ??= StoreConfig._internal(store, apiKey);
    return _instance!;
  }

  StoreConfig._internal(this.store, this.apiKey);

  static StoreConfig get instance {
    return _instance!;
  }

  static bool isForAppleStore() => instance.store == Store.appleStore;

  static bool isForGooglePlay() => instance.store == Store.googlePlay;
}
