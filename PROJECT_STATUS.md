# Calculator - Project Status

## Current Status
**OPEN SOURCE RELEASE CANDIDATE**. The application is verified complete, architected with Riverpod and GoRouter, and incorporates pure-Dart domain engines backing 150+ specialized calculation tools and a 15-category unit converter.

## Verified Complete
- Math Engine & Expression Evaluator (custom AST tokenizer, parser, and evaluator supporting functions, parentheses, percentages, and trigonometry).
- Theme System (6 custom color palettes, Light and Dark modes, dynamic typography).
- History & Hive Local Storage (offline-first, zero telemetry).
- Routing & Deep Linking (`go_router`) with web state serialization.
- 150+ Specialized Tools across Science, Engineering, Mathematics, Finance, and Everyday utilities.
- Web PWA configuration & manifest.
- Standalone Android build setup (offline FOSS sideloading).
- Desktop runners for Windows, macOS, and Linux.

## Known Issues
- None confirmed from static code analysis.
- Web download integration verified with `package:web`.

## Current Platform Status
- **Web**: Production PWA ready for static GitHub Pages hosting.
- **Android**: Standalone APK release ready for FOSS distribution and direct sideloading.
- **Desktop**: Native runners ready for Windows, macOS, and Linux builds.

## Testing Status
- 591 automated tests passing with zero regressions.
- Static analysis clean with 0 warnings.

## Release Distribution Model
- **Public GitHub Repository**: Published as 100% Free and Open Source Software (FOSS).
- **No Store Dependencies**: Decommissioned all Google Play Store and Apple App Store submission paths.
- **Community Maintained**: Distributed under the MIT license.

## Immediate Next Steps
- Push repository to the public GitHub repository.
- Tag release `v1.0.0`.
- Enable GitHub Pages for live interactive web usage.
- Provide standalone binaries via GitHub Releases.
