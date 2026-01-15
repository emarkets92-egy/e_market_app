class MarkReadRequestModel {
  final List<String>? messageIds;

  MarkReadRequestModel({this.messageIds});

  Map<String, dynamic> toJson() {
    return {
      if (messageIds != null) 'messageIds': messageIds,
    };
  }
}
