# Saber / Opennote — Claude Agent Guidelines

See [**`AGENTS.md`**](AGENTS.md) for authoritative project architecture, gesture detection parameters, canvas stamping invariants, and Flutter tool state rules.

## Core Invariants:
1. **Tool State Singleton Identity**: Never re-instantiate tool singletons (`Pen`, `Eraser`, `Select`, `DraftingTool`, `StudyTape`). Mutate in-place.
2. **Canvas Stamping**: Project to viewport or tap point, never hardcode `(0, 0)`.
3. **Infinite Canvas Culling**: Viewport clamp pattern drawing to avoid unconstrained canvas rendering.
4. **Environment Safety**: Follow global toolchain rules (dev tools in `E:\03_Devops`, partition `D:\` protection).
