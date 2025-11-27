## Android (APK)

```bash
flutter build apk --release
```

## iOS (IPA)

```bash
flutter build ipa --release
```

## macOS (DMG/PKG)

```bash
flutter build macos --release
# Note: Further packaging (like create-dmg) is often required to create a .dmg file from the .app bundle.
```

## Windows (MSI/EXE)

```bash
flutter build windows --release
# Note: To generate an MSI or EXE installer, you typically use a tool like Inno Setup or WiX Toolset on the build output.
```
