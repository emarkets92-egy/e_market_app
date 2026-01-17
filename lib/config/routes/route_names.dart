class RouteNames {
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  static const String completeProfile = '/complete-profile';

  // Main routes
  static const String home = '/home';
  static const String subscriptionSelection = '/subscription-selection';
  static const String inbox = '/inbox';
  static const String opportunities = '/opportunities';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // Product routes
  static const String productList = '/products';
  static const String productDetail = '/products/:id';
  static const String marketSelection = '/market-selection';

  // Subscription routes
  static const String profileList = '/profiles';
  static const String profileDetail = '/profiles/:id';
  static const String shipmentRecordsList = '/profiles/:profileId/shipment-records';
  static const String analysis = '/analysis';
  static const String competitiveAnalysis = '/analysis/competitive';
  static const String pestleAnalysis = '/analysis/pestle';
  static const String swotAnalysis = '/analysis/swot';
  static const String marketPlan = '/analysis/market-plan';

  // Chat routes
  static const String conversations = '/conversations';
  static const String chat = '/chat';
  static String chatWithRoomId(String roomId) => '/chat/$roomId';
  static String chatWithRecipient(String recipientProfileId) => '/chat?recipientProfileId=$recipientProfileId';
  static const String searchUnlockedProfiles = '/chat/search-profiles';

  // Sales Request routes
  static const String salesRequestCreate = '/sales-requests/create';
  static const String salesRequestList = '/sales-requests';
  static String salesRequestDetail(String id) => '/sales-requests/$id';
}
