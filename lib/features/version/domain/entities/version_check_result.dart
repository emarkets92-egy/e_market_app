class VersionCheckResult {
  final String latestVersion;
  final String minimumVersion;
  final bool updateRequired;
  final bool forceUpdate;
  final String? downloadUrl;
  final String? releaseNotes;

  VersionCheckResult({
    required this.latestVersion,
    required this.minimumVersion,
    required this.updateRequired,
    required this.forceUpdate,
    this.downloadUrl,
    this.releaseNotes,
  });

  factory VersionCheckResult.fromJson(Map<String, dynamic> json) {
    return VersionCheckResult(
      latestVersion: json['latestVersion'] as String,
      minimumVersion: json['minimumVersion'] as String,
      updateRequired: json['updateRequired'] as bool,
      forceUpdate: json['forceUpdate'] as bool? ?? false,
      downloadUrl: json['downloadUrl'] as String?,
      releaseNotes: json['releaseNotes'] as String?,
    );
  }
}

