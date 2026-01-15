import 'unlocked_profile_model.dart';

class SearchProfilesResponseModel {
  final List<UnlockedProfileModel> profiles;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  SearchProfilesResponseModel({
    required this.profiles,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory SearchProfilesResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      final profilesList = json['profiles'];
      if (profilesList == null) {
        throw Exception('profiles is null in JSON: $json');
      }
      
      final profiles = (profilesList)
          .map((item) {
            try {
              return UnlockedProfileModel.fromJson(item as Map<String, dynamic>);
            } catch (e) {
            rethrow;
          }
        }).toList();

      return SearchProfilesResponseModel(
        profiles: profiles,
        total: (json['total'] as num?)?.toInt() ?? 0,
        page: (json['page'] as num?)?.toInt() ?? 1,
        limit: (json['limit'] as num?)?.toInt() ?? 20,
        totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'profiles': profiles.map((p) => p.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}
