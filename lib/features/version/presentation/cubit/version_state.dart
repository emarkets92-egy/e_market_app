abstract class VersionState {
  const VersionState();
}

class VersionInitial extends VersionState {
  const VersionInitial();
}

class VersionChecking extends VersionState {
  const VersionChecking();
}

class VersionUpToDate extends VersionState {
  const VersionUpToDate();
}

class VersionUpdateRequired extends VersionState {
  final String currentVersion;
  final String latestVersion;
  final String? downloadUrl;
  final String? releaseNotes;

  const VersionUpdateRequired({required this.currentVersion, required this.latestVersion, this.downloadUrl, this.releaseNotes});
}

class VersionCheckError extends VersionState {
  final String message;

  const VersionCheckError({required this.message});
}
