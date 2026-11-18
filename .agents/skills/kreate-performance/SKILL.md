---
name: kreate-performance
description: >-
  Flutter performance guidelines for Calculator.
  Rules for rebuild minimization, Riverpod optimization, blur effects, and general Dart performance.
---

# Flutter Performance

## Rebuild Minimization
- Use `const` widgets everywhere.
- Do not put expensive calculations directly inside `build()` methods.
- Use `ConsumerWidget` or `Consumer` strategically. Bind to the deepest possible node to avoid rebuilding entire screens on minor state changes.
- Use `ref.watch(provider.select((v) => v.property))` to listen to specific fields when objects are large.

## Visual Effects
- **Blur / BackdropFilter**: Glassmorphism is expensive. Do not nest blurs. Do not put blurs over large animated areas if possible. Use `KGlassCard` as it has been standardized.
- **Shadows**: Keep `blurRadius` reasonable. Do not use 10+ shadows on a single screen.

## Memory & Collections
- **History/Hive**: Large datasets (10,000+ entries) require pagination or lazy loading. Do not fetch everything blindly if it impacts startup.
- **Lists**: Always use `ListView.builder` or `ListView.separated` for dynamic lists (e.g. History). Never use `SingleChildScrollView(child: Column(...))` for unbounded data.
