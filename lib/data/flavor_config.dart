/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

class FlavorConfig {
  FlavorConfig._();

  static var _flavor = '';
  static String get flavor => _flavor;

  static var _appStore = '';
  static String get appStore => _appStore;

  static var _shouldCheckForUpdatesByDefault = true;
  static bool get shouldCheckForUpdatesByDefault =>
      _shouldCheckForUpdatesByDefault;

  static void setup({
    String flavor = '',
    String appStore = '',
    bool shouldCheckForUpdatesByDefault = true,
  }) {
    _flavor = flavor;
    _appStore = appStore;
    _shouldCheckForUpdatesByDefault = shouldCheckForUpdatesByDefault;
  }

  static void setupFromEnvironment() => setup(
    flavor: const String.fromEnvironment('FLAVOR'),
    appStore: const String.fromEnvironment('APP_STORE'),
    shouldCheckForUpdatesByDefault: const bool.fromEnvironment(
      'UPDATE_CHECK',
      defaultValue: true,
    ),
  );
}
