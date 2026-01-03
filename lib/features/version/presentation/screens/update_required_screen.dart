import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cubit/version_state.dart';
import '../../services/windows_update_installer.dart';

class UpdateRequiredScreen extends StatefulWidget {
  final VersionUpdateRequired state;

  const UpdateRequiredScreen({super.key, required this.state});

  @override
  State<UpdateRequiredScreen> createState() => _UpdateRequiredScreenState();
}

class _UpdateRequiredScreenState extends State<UpdateRequiredScreen> {
  final WindowsUpdateInstaller _installer = WindowsUpdateInstaller();

  bool _installing = false;
  double? _progress;
  String? _error;

  Future<void> _openDownloadLink() async {
    if (widget.state.downloadUrl != null && widget.state.downloadUrl!.isNotEmpty) {
      final uri = Uri.parse(widget.state.downloadUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try to open in browser
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    }
  }

  Future<void> _downloadAndInstallWindows() async {
    final url = widget.state.downloadUrl;
    if (url == null || url.isEmpty) return;

    setState(() {
      _installing = true;
      _progress = 0;
      _error = null;
    });

    try {
      final file = await _installer.downloadInstaller(
        downloadUrl: url,
        versionLabel: widget.state.latestVersion,
        sha256Hex: null,
        onProgress: (p) => setState(() => _progress = p),
      );

      await _installer.installInnoSetup(installerExe: file, installerArgs: null);

      // Installer runs outside the app and may need to replace files.
      exit(0);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _installing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.system_update, size: 80, color: Colors.white),
                    const SizedBox(height: 24),
                    Text(
                      'Update Required',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'A new version of the app is available.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current: ${widget.state.currentVersion}\nLatest: ${widget.state.latestVersion}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white60),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.state.releaseNotes != null && widget.state.releaseNotes!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What\'s New:',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(widget.state.releaseNotes!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                    if (_error != null && _error!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.withAlpha(38), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    if (_installing) ...[
                      const SizedBox(height: 24),
                      LinearProgressIndicator(value: _progress),
                      const SizedBox(height: 8),
                      Text(
                        _progress != null ? 'Downloading ${((_progress ?? 0) * 100).toStringAsFixed(0)}%' : 'Downloading...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ],
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _installing
                          ? null
                          : (widget.state.downloadUrl != null && widget.state.downloadUrl!.isNotEmpty)
                          ? (Platform.isWindows ? _downloadAndInstallWindows : _openDownloadLink)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: Text(_installing ? 'Updating...' : 'Update Now', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    if (widget.state.downloadUrl == null || widget.state.downloadUrl!.isEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Download link not available', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
