class VersionCheckResult {
  final String latestVersion;
  final String minimumVersion;
  final bool updateRequired;
  final bool forceUpdate;
  final String? downloadUrl;
  final String? releaseNotes;
  final String? sha256;
  final List<String>? installerArgs;

  VersionCheckResult({
    required this.latestVersion,
    required this.minimumVersion,
    required this.updateRequired,
    required this.forceUpdate,
    this.downloadUrl,
    this.releaseNotes,
    this.sha256,
    this.installerArgs,
  });

  factory VersionCheckResult.fromJson(Map<String, dynamic> json) {
    final dynamic argsRaw = json['installerArgs'];
    List<String>? args;
    if (argsRaw is List) {
      args = argsRaw.whereType<String>().toList();
    } else if (argsRaw is String && argsRaw.trim().isNotEmpty) {
      // Allow a single string like "/SILENT /VERYSILENT /NORESTART"
      args = argsRaw.trim().split(RegExp(r'\s+'));
    }

    return VersionCheckResult(
      latestVersion: json['latestVersion'] as String,
      minimumVersion: json['minimumVersion'] as String,
      updateRequired: json['updateRequired'] as bool,
      forceUpdate: json['forceUpdate'] as bool? ?? false,
      downloadUrl: json['downloadUrl'] as String?,
      releaseNotes: json['releaseNotes'] as String?,
      sha256: json['sha256'] as String?,
      installerArgs: args,
    );
  }
}

