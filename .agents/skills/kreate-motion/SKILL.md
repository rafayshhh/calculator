---
name: kreate-motion
description: >-
  Rules for motion and micro-interactions in Calculator.
  Defines animation hierarchy, use of flutter_animate, and performance requirements.
---

# Motion + Micro-interactions

## Animation Hierarchy
1. **LEVEL 1: Instant feedback**: Tap ripples, glassmorphic button presses. Built into Flutter's `InkWell` or `GestureDetector`.
2. **LEVEL 2: Subtle micro-interactions**: Favorites toggling (ScaleTransition via `AnimatedSwitcher`), Error shaking (`.shakeX()`).
3. **LEVEL 3: Screen transitions**: Fade/slide when entering a new tool (`.animate().fadeIn().slideY()`).
4. **LEVEL 4: Hero/brand animations**: Splash screen pulse/glow, logo treatments.

## Tooling
- Use **flutter_animate** for linear entrance animations (`.fadeIn()`, `.slide()`).
- Use native **AnimatedSwitcher** or **AnimatedContainer** for state-based micro-interactions.
- **Do NOT** add new animation dependencies (like Lottie or Rive) unless explicitly required for a complex vector animation.

## Guidelines
- Keep animations fast (150ms - 400ms).
- Do not let animations block the user from interacting with the app.
- Respect reduced motion (use `.fadeIn()` instead of heavy slides if needed).
- Avoid animation fatigue. Do not animate every single button on a screen.
