# Testing Rikit

Run the same quality checks used by CI before opening a pull request:

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Golden snapshots

Golden tests use fixed logical desktop sizes and Flutter's deterministic test font. Review visual changes before updating snapshots:

```sh
flutter test --update-goldens
flutter test
```

Commit updated PNG files only when the visual change is intentional and has been inspected. CI runs the golden suite on Ubuntu; macOS and Windows jobs compile the native desktop applications without regenerating snapshots.
