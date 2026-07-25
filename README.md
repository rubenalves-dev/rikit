# Rikit

Rikit is a private, desktop-first collection of focused developer tools for macOS and Windows. The first tool is a precision-safe JSON formatter with validation, natural key sorting, optional token normalization, native file workflows, and local-only activity insights.

## Run locally

```sh
flutter pub get
flutter run -d macos
```

Use `windows` instead of `macos` on Windows.

## Quality

See [docs/testing.md](docs/testing.md) for local checks and intentional golden-snapshot updates. GitHub Actions runs formatting, analysis, tests, goldens, and native macOS/Windows release builds for pull requests.
