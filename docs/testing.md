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

The test harness permits at most a 2.5% pixel difference to absorb Skia rasterization differences between macOS development machines and Ubuntu CI. Structural widget tests still assert layout and behavior independently, and larger visual changes fail with Flutter's normal diff artifacts.
