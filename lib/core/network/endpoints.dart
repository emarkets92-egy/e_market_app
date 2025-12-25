class Endpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String completeProfile = '/auth/complete';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String updateProfile = '/auth/profile';

  // Products
  static const String products = '/products';
  static String productById(String id) => '/products/$id';

  // Subscriptions
  static const String subscriptions = '/subscriptions';
  static const String exploreMarket = '/subscriptions/explore-market';
  static const String unlockProfileContact = '/subscriptions/unlock/profile-contact';
  static const String unlockMarketAnalysis = '/subscriptions/unlock/market-analysis';
  static const String unlockMarketPlan = '/subscriptions/unlock/market-plan';
  static const String pointsBalance = '/subscriptions/points/balance';
  static const String unlocks = '/subscriptions/unlocks';
  static const String pointsTransactions = '/subscriptions/points/transactions';

  // Localization
  static const String countries = '/localization/countries';
  static const String languages = '/localization/languages';
}

