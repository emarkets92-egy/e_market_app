class Endpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String completeProfile = '/auth/complete';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String getProfile = '/auth/profile';
  static const String updateProfile = '/auth/profile';

  // Products
  static const String products = '/products';
  static String productById(String id) => '/products/$id';

  // Subscriptions
  static const String subscriptions = '/subscriptions';
  static const String exploreMarket = '/subscriptions/explore-market';
  static const String unlock = '/subscriptions/unlock';
  static const String pointsBalance = '/subscriptions/points/balance';
  static const String pointsTransactions = '/subscriptions/points/transactions';
  static String shipmentRecords(String profileId) => '/subscriptions/profiles/$profileId/shipment-records';

  // Localization
  static const String countries = '/localization/countries';
  static const String languages = '/localization/languages';

  // Version Check
  static const String checkVersion = '/app/version/check';
}
