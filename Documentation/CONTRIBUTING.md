# Contributing to Calculator

Thank you for your interest in contributing to **Calculator**! We welcome contributions from developers, mathematicians, scientists, students, and designers worldwide.

As an open-source project published under the **MIT License**, our goal is to maintain a robust, mathematically rigorous, offline-first calculation platform.

---

## 📜 Code of Conduct

All contributors and maintainers are expected to adhere to our [Code of Conduct](../CODE_OF_CONDUCT.md). Please treat all participants with respect, empathy, and constructive collaboration.

---

## 💡 Ways to Contribute

1. **Add New Specialized Tools**: Introduce calculators for your domain (civil engineering, optics, astronomy, acoustics, cryptography).
2. **Report Bugs**: Identify mathematical calculation inaccuracies, edge-case crashes, or layout overflows.
3. **Enhance Documentation**: Fix typos, add LaTeX formulas, clarify usage instructions, or translate guides.
4. **Improve Accessibility**: Audit screen-reader labels, contrast ratios, and keyboard navigation.

---

## 🍴 Contribution Workflow

### 1. Fork & Clone
```bash
git clone https://github.com/<your-username>/calculator.git
cd calculator
git remote add upstream https://github.com/rafayshhh/calculator.git
```

### 2. Create a Feature Branch
Use descriptive branch names:
```bash
git checkout -b feature/acoustic-impedance-calculator
# or
git checkout -b fix/quadratic-imaginary-roots
```

### 3. Make Your Changes
Follow the architectural standards detailed in the [Developer Guide](DEVELOPMENT_GUIDE.md):
- Keep math logic pure Dart within `domain/`.
- Never hardcode colors; use `context.kPalette`.
- Add unit tests for every newly created domain engine.

### 4. Verify Code Quality & Testing
Before opening a PR, ensure all checks pass:
```bash
# Format code
dart format --line-length 80 .

# Static analysis
flutter analyze

# Execute test suite
flutter test
```
All checks must pass with **0 errors and 0 warnings**.

### 5. Commit Guidelines
We follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat: add torque angle calculation support`
- `fix: resolve division by zero handling in density engine`
- `docs: update physics engine formulas in reference guide`
- `test: add edge-case unit tests for matrix determinant`
- `refactor: clean up keypad layout widget hierarchy`

### 6. Submit a Pull Request
Push your branch to your fork and submit a PR to `main`:
- Provide a concise description of the changes.
- Cite mathematical formulas or textbook sources for new engines.
- Verify that automated CI passes.
