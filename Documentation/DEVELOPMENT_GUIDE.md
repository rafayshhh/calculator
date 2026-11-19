# Calculator — Developer & Contributor Guide

Welcome to the development guide for **Calculator**. This project is a community-driven, 100% Free and Open Source (FOSS) utility suite published on GitHub.

---

## 🛠️ Prerequisites & Environment Setup

To build and run Calculator locally, you will need:

1. **Flutter SDK**: Version `3.13.0` or higher (`stable` channel recommended).
2. **Dart SDK**: Version `3.13.0` or higher (bundled with Flutter).
3. **Git**: For version control.
4. **Platform Toolchains** (depending on your target operating system):
   - **Web**: Google Chrome or any modern Chromium/WebKit browser.
   - **Windows**: Visual Studio 2022 with the "Desktop development with C++" workload installed.
   - **Linux**: Standard build essentials (`clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`).
   - **macOS**: Xcode with Command Line Tools.
   - **Android**: Android SDK (API 34+ recommended).

Verify your local installation:
```bash
flutter doctor -v
```

---

## 🚀 Cloning & Initializing the Project

```bash
# 1. Clone the repository
git clone https://github.com/rafayshhh/calculator.git
cd calculator

# 2. Fetch Flutter package dependencies
flutter pub get

# 3. Verify static analysis passes with 0 warnings
flutter analyze

# 4. Execute the automated test suite
flutter test
```

---

## 💻 Running the App Locally

### Web (Fastest for UI & Tool iteration)
```bash
flutter run -d chrome
```

### Desktop (Native Performance)
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

### Android (Mobile & Emulator)
```bash
flutter run -d android
```

---

## 📏 Core Development Principles & Constraints

When submitting code to Calculator, pull requests must strictly observe these architecture rules:

### 1. Pure Dart Math Logic
- **No Third-Party Math Dependencies**: All mathematical models, numerical methods, conversions, and algorithms must be implemented in pure Dart within `domain/` directories.
- **Deterministic & Idempotent**: Domain functions must take inputs and return outputs without reading ambient mutable state or making network calls.

### 2. Strictly Offline-First
- **Zero Telemetry or Analytics**: Do not import Firebase Analytics, Mixpanel, Sentry, or any cloud logging libraries.
- **Zero Remote HTTP Requests**: All calculations must operate 100% offline. Never introduce external API calls.

### 3. Separation of Concerns
- **UI Widgets Must Not Compute**: Keep UI components purely presentation-focused. Calculations belong in domain engines, and application state belongs in Riverpod Notifiers.
- **Riverpod for Global State**: Avoid `setState` for state shared across screens or workspaces. Use `flutter_riverpod` notifiers.

### 4. Semantic Theming
- **Never Hardcode Colors**: Do not use `Colors.blue`, `Color(0xFF...)`, or `Colors.white` inside feature widgets.
- **Consume `context.kPalette`**: Always use dynamic palette tokens (`palette.primary`, `palette.surface`, `palette.textPrimary`, `palette.glassBorder`).
- **Use Spacing Constants**: Use `KSpacing.sm`, `KSpacing.md`, `KSpacing.lg`, and `KRadius.md` instead of arbitrary numeric padding.

---

## 🔨 Step-by-Step: Adding a New Specialized Tool

Adding a new tool to Calculator follows a clean 4-step workflow:

### Step 1: Create the Pure-Dart Domain Engine
Create `lib/features/tools/<category>/domain/<tool_name>_engine.dart`:
```dart
class MyToolEngine {
  static MyToolResult calculate({required double inputVal}) {
    if (inputVal < 0) {
      throw ArgumentError('Input must be non-negative');
    }
    final result = inputVal * 42.0;
    return MyToolResult(value: result, formula: 'R = V × 42');
  }
}

class MyToolResult {
  final double value;
  final String formula;
  const MyToolResult({required this.value, required this.formula});
}
```

### Step 2: Write the Engine Unit Tests
Create `test/features/tools/<category>/<tool_name>_engine_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kreate_calculator/features/tools/<category>/domain/<tool_name>_engine.dart';

void main() {
  group('MyToolEngine Tests', () {
    test('Calculates expected value', () {
      final res = MyToolEngine.calculate(inputVal: 2.0);
      expect(res.value, equals(84.0));
      expect(res.formula, isNotEmpty);
    });

    test('Throws on negative input', () {
      expect(() => MyToolEngine.calculate(inputVal: -1.0), throwsArgumentError);
    });
  });
}
```

### Step 3: Implement the Presentation Screen
Create `lib/features/tools/<category>/presentation/<tool_name>_screen.dart` utilizing `ToolPageScaffold` and `ResultDisplayCard`:
```dart
import 'package:flutter/material.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../domain/<tool_name>_engine.dart';

class MyToolScreen extends StatefulWidget {
  const MyToolScreen({super.key});

  @override
  State<MyToolScreen> createState() => _MyToolScreenState();
}

class _MyToolScreenState extends State<MyToolScreen> {
  double _input = 10.0;
  MyToolResult? _result;

  @override
  void initState() {
    super.initState();
    _compute();
  }

  void _compute() {
    setState(() {
      _result = MyToolEngine.calculate(inputVal: _input);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'my_tool',
      title: 'My Custom Tool',
      description: 'Calculates custom parameters',
      icon: Icons.calculate_outlined,
      onBack: () => Navigator.of(context).pop(),
      onRefresh: () => setState(() => _input = 10.0),
      inputs: [
        PremiumNumericField(
          label: 'Input Value',
          value: _input.toString(),
          onChanged: (val) {
            final parsed = double.tryParse(val) ?? 0.0;
            setState(() => _input = parsed);
            _compute();
          },
        ),
      ],
      results: [
        if (_result != null)
          ResultDisplayCard(
            label: 'Calculated Output',
            value: '${_result!.value}',
            formula: _result!.formula,
          ),
      ],
    );
  }
}
```

### Step 4: Register in Router & Tools Directory
Add route entry to `lib/app/router/app_router.dart` and register the tool definition metadata in `lib/features/tools/domain/tool_definition.dart`.

---

## 📦 Building Standalone Release Artifacts

Because Calculator is published as a public GitHub FOSS project, release artifacts can be built directly for distribution via GitHub Releases:

### Web Production Bundle (PWA)
```bash
flutter build web --release --pwa-strategy=offline-first
# Output: build/web/
```

### Android APK (Standalone FOSS Sideload)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Windows Desktop Executable
```bash
flutter build windows --release
# Output: build/windows/x64/runner/Release/
```

### Linux Desktop Bundle
```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

### macOS Application
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/
```
