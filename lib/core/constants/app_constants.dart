class AppConstants {
  // User Types
  static const int userTypeImporter = 1;
  static const int userTypeExporter = 2;
  static const int userTypeServiceProvider = 3;
  
  // Market Types
  static const String marketTypeTarget = 'targetMarkets';
  static const String marketTypeOther = 'otherMarkets';
  static const String marketTypeImporter = 'importerMarkets';
  
  // Analysis Types
  static const String analysisTypeCompetitive = 'COMPETITIVE_ANALYSIS';
  static const String analysisTypePestle = 'PESTLE_ANALYSIS';
  static const String analysisTypeSwot = 'SWOT_ANALYSIS';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int defaultPage = 1;
  
  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUser = 'user';
  static const String keyLocale = 'locale';
  
  // Unlock Costs (defaults, may be overridden by backend)
  static const int defaultUnlockCost = 1;
}

