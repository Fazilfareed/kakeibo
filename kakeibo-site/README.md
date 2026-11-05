# Kakeibo landing site

This folder is the public website for Kakeibo. The release APKs are in the sibling
folder `../kakeibo-app-build`.

## Structure

- `../kakeibo-app-build/` — the signed release APKs (version 1.0.0)
  - `kakeibo-1.0.0-arm64-v8a.apk` — for most current Android phones (23.7 MB)
  - `kakeibo-1.0.0-armeabi-v7a.apk` — for older 32-bit phones (21.2 MB)
- `guide/` — the user guide, as `Kakeibo_User_Guide.html` (opens in a browser) and `Kakeibo_User_Guide.pdf`
- `index.html` — the landing page
- `downloads/` — copies of the two APKs for the download buttons (made by `sync-downloads.ps1`; git-ignored)
- `images/`, `fonts/` — screenshots and the app fonts, so the page works offline
- `sync-downloads.ps1` — run before publishing to refresh `downloads/` from `../kakeibo-app-build`

## Checksums (SHA-256)

```
46ceb30c0ab283eef82a61db9a095966f8d03174384d771be5e776ba920b0cc6  kakeibo-1.0.0-arm64-v8a.apk
aba1b88fb993c5e455aa2d40281b301cc7a6447d77b9bdb1bd11a4e5a14a8c84  kakeibo-1.0.0-armeabi-v7a.apk
```

## Notes

- The APKs are signed with the Kakeibo release key. Only that key can publish updates.
  Keep the key folder (`kakeibo-signing`) out of this site.
- The site needs no server code: it is plain HTML, CSS and files.
- When the site is published, copy the two APKs into the published site's
  downloads folder, so the download links work.
