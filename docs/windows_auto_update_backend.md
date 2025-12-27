# Windows Auto-Update (Backend Contract)

Your Flutter app calls `GET /app/version/check` (see `lib/core/network/endpoints.dart`) on startup before login.

For **Windows auto-update**, the backend must return a **direct downloadable Inno Setup installer URL** (ending in `.exe`), not a GitHub release page.

## Required response (example)

```json
{
  "latestVersion": "1.0.13",
  "minimumVersion": "1.0.13",
  "updateRequired": true,
  "forceUpdate": true,
  "downloadUrl": "https://api.yourdomain.com/downloads/windows/e_market_app_1.0.13.exe",
  "releaseNotes": "New features and bug fixes"
}
```

## Recommended optional fields

These make the updater safer and more flexible:

```json
{
  "sha256": "hex_sha256_of_the_exe",
  "installerArgs": ["/SILENT", "/VERYSILENT", "/NORESTART"]
}
```

## Hosting (you selected backend-static)

Serve the installer publicly from your backend, e.g.:

- `GET /downloads/windows/e_market_app_1.0.13.exe` → returns the `.exe` file

Notes:
- Ensure correct headers: `Content-Type: application/octet-stream`.
- Support large files (reverse proxy limits, timeouts).
- Prefer immutable filenames (include version) to avoid caching issues.


