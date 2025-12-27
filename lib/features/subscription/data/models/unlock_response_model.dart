import 'unlock_item_model.dart';
import 'profile_model.dart';
import 'analysis_models.dart';

class UnlockResponseModel {
  final bool unlocked;
  final int cost;
  final String message;
  final int pointsBalance;
  final UnlockContentData? data;

  UnlockResponseModel({
    required this.unlocked,
    required this.cost,
    required this.message,
    required this.pointsBalance,
    this.data,
  });

  factory UnlockResponseModel.fromJson(Map<String, dynamic> json) {
    return UnlockResponseModel(
      unlocked: json['unlocked'] as bool,
      cost: (json['cost'] as num).toInt(),
      message: json['message'] as String,
      pointsBalance: (json['pointsBalance'] as num).toInt(),
      data: json['data'] != null
          ? UnlockContentData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unlocked': unlocked,
      'cost': cost,
      'message': message,
      'pointsBalance': pointsBalance,
      if (data != null) 'data': data!.toJson(),
    };
  }
}

class UnlockContentData {
  final ContentType contentType;
  final dynamic contentData; // Can be ProfileModel, CompetitiveAnalysisModel, etc.

  UnlockContentData({
    required this.contentType,
    required this.contentData,
  });

  factory UnlockContentData.fromJson(Map<String, dynamic> json) {
    final contentTypeString = json['contentType'] as String;
    final contentType = ContentType.fromString(contentTypeString) ??
        ContentType.profileContact;
    final dataJson = json['data'] as Map<String, dynamic>;

    dynamic contentData;
    switch (contentType) {
      case ContentType.profileContact:
        contentData = ProfileModel.fromJson(dataJson);
        break;
      case ContentType.competitiveAnalysis:
        contentData = CompetitiveAnalysisModel.fromJson(dataJson);
        break;
      case ContentType.pestleAnalysis:
        contentData = PESTLEAnalysisModel.fromJson(dataJson);
        break;
      case ContentType.swotAnalysis:
        contentData = SWOTAnalysisModel.fromJson(dataJson);
        break;
      case ContentType.marketPlan:
        contentData = MarketPlanModel.fromJson(dataJson);
        break;
      case ContentType.shipmentRecords:
        // Shipment records are handled differently - unlock just marks them as seen
        // The actual data comes from the shipment records API
        contentData = null;
        break;
    }

    return UnlockContentData(
      contentType: contentType,
      contentData: contentData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contentType': contentType.toApiString(),
      'data': _contentDataToJson(contentData),
    };
  }

  dynamic _contentDataToJson(dynamic contentData) {
    if (contentData is ProfileModel) {
      return contentData.toJson();
    } else if (contentData is CompetitiveAnalysisModel) {
      return contentData.toJson();
    } else if (contentData is PESTLEAnalysisModel) {
      return contentData.toJson();
    } else if (contentData is SWOTAnalysisModel) {
      return contentData.toJson();
    } else if (contentData is MarketPlanModel) {
      return contentData.toJson();
    }
    return {};
  }
}
