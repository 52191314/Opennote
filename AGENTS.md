# AI Agent Instructions

AI-generated code is not accepted upstream in saber-notes/saber.
But if you are using AI for other purposes, like for personal use or maintaining a community fork of Saber, follow these instructions.

Note: These instructions are fine-tuned for AI. If you are a human, see [CONTRIBUTING.md](.github/CONTRIBUTING.md) instead.

AI agents can find more instructions if needed on the wiki, e.g. [Maintainer notes](https://github.com/saber-notes/saber/wiki/Maintainer-notes).

## Style

- Your code should be idiomatic and readable.
- Avoid unnecessary complexity.
- Avoid nesting where possible. Guard statements are hugely preferable.
- Avoid big functions, they should do one thing and do it well. The entire function should be easily understood from the name alone.
- Document public members like widgets, classes, and methods in dartdoc comments.
- Avoid obvious comments that add no value. Avoid inline comments and comments within the body of methods, since they typically just add clutter and highlight that your code may be too convoluted.
- Follow good Flutter coding practices, like keeping widgets small and being mindful of the performance impact of `setState`.
- Always credit your AI agent's model name and any other relevant information at the top of each file changed (even if it's just a small change or refactor), e.g.:
  ```dart
  /// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
  library;
  ```
  Never remove any AI credits. They are important for transparency.

## Testing

- Run the app and ensure your changes work as expected.
- Write tests for as much of your change as possible.
- Ideally, write tests *before* implementing the feature/fix. Follow the TDD (Test-Driven Development) approach. This ensures you've found the precise issue you're trying to fix.
- Don't delete existing tests. If they're failing, that highlights something wrong with your code. Don't say "we'll fix it later": later never comes. If you really cannot fix it, defer to a human or a more complex AI agent.

## Gesture & Canvas Tools

- When building or tuning pen/stylus gesture detectors (e.g. scribble-to-erase, circle-to-select, shape recognition):
  - **Physical scale independence**: Do not couple human touch gesture geometry to digital stroke widths (e.g. bounding box size scaling directly with pen width). Human gestures operate on physical human scales (20–400 px) regardless of pen thickness.
  - **No premature lock-out**: Never permanently lock out gesture recognition after a fixed initial point window; touch sampling rates (60–120Hz) mean multi-stroke gestures take dozens of points. Use a sliding window of recent points instead.
  - **Discrete hit-testing & lead-in erasure**: For gesture-driven erasing, hit testing must account for discrete sampling intervals with a generous effective radius (e.g. >= 24 px) and retroactively erase all points traversed during the gesture leading up to detection.
  - **Immediate visual cleanup**: Clear in-flight ink previews (`Pen.currentStroke = null`) upon gesture detection to prevent frozen partial strokes on screen.
  - **Discoverability**: Expose tool settings in both relevant tool modals and global app settings with intuitive icons and sensible defaults.

- **Toolbar & Tool State Integrity**:
  - **Singleton identity preservation**: Never re-instantiate or overwrite tool singletons (`Pen.currentPen`, `Eraser.currentEraser`, `Select.currentSelect`, `DraftingTool.currentDrafting`, `StudyTape.currentStudyTape`) when the user selects a preset, style, or color. Mutate existing singletons in-place or update their options. Detaching `currentTool` from its singleton breaks reference checks (`_isCurrent(tool)`) and leaves toolbar and bottom bar buttons permanently stuck.

- **Canvas Element & Media Stamping**:
  - **Viewport & tap-based placement**: Never hardcode stamped element, note, sticker, shape, or photo placement to static coordinates (e.g. `(0, 0)`, `(20, 20)`, or static `page.size / 2`). On infinite canvas or scrolled views, static coordinates place elements offscreen in the extreme top-left corner. Always prioritize the user's recent canvas tap position (`_lastCanvasTapPosition` from `onDrawStart`), falling back to projecting the visible screen viewport center (`renderBox.globalToLocal(screenCenter)`).
  - **Immediate auto-selection & handles**: Newly stamped elements and media must immediately be selected into `Select.currentSelect` (`selectStrokes` / `selectImages`) with handles updated (`_updateSelectionHandles`). This allows immediate user manipulation (move, resize, rotate) and ensures toolbar actions like 'Delete' immediately affect the newly placed element.

- **Infinite Canvas Performance**:
  - **Viewport culling for patterns**: In infinite canvas mode, canvas bounds are virtually unbounded. Repeating background grids, lines, and dot patterns must strictly be culled and clamped to the visible viewport rect (`cullRect` / visible viewport), never rendered across unconstrained or infinite canvas bounds.

## Builds & CI

- **Do not trigger Android or Windows builds**: Never trigger `Build for Android` or `Build for Windows` GitHub Action workflows (e.g. via `gh workflow run` or manual dispatch).
- **Target platforms**: Only run/monitor `Run tests` and `Build iOS` (or `Build for iOS`) workflows when pushing changes or inspecting CI status.

### Homelab macOS Runner (`aspire5-server`)
- **Host**: `homelab` (`192.168.1.6`), managed via Docker Compose at `/opt/dockur-macos`.
- **macOS Container**: `macos-runner` (`dockurr/macos:latest` running macOS Sonoma 14 with KVM acceleration).
- **Web Console**: `http://192.168.1.6:8006` (or `http://homelab:8006`).
- **macOS Guest SSH**:
  - Host Port: `50922` -> Guest Port `22`
  - Account Name: `x`
  - Username: `xx`
  - Password: `1314xxx`
- **Memory Safeguards**:
  - Host has a 16 GiB swapfile (`/swapfile_docker_osx`, total 20 GiB swap active).
  - Production containers (`vaultwarden`, `caddy`, `nexuspay`, etc.) are immunized with `oom_score_adj: -1000` via systemd `oom-guard.timer`.
  - The macOS container has `oom_score_adj: 500` to sacrifice itself first if memory is starved.

## Commits
- Follow the Conventional Commits format.
- Always include one or more emojis that represent your commit. Additionally include the sparkle emoji ✨.
- Always credit your AI agent's model name and any other relevant information.
- Include a short paragraph explaining how another AI agent could safely modify this change in the future.
- Keep commits small, focused, and atomic. They should be easily revertible.
- If your commit adds a new translatable string, only include the English translation in the commit. Then make a secondary commit like `i18n: auto translations 🗺️✨` with all the other languages' translations. This keeps the commit readable for other people, without clutter from a bajillion different string variants.

- A good commit message could be:
  ```
  fix: error with empty files 🪹✨
  
  Fixes a bug in FileManager.readFile where it would throw an error when reading an empty file.

  To safely modify this change in the future, another AI agent could follow these steps:
  1. Identify the root cause of the bug.
  2. Propose a solution that addresses the root cause.
  3. Write tests for the proposed solution.
  4. Implement the solution and run the tests to ensure it works as expected.
  
  🤖 Generated with Claude Code
  ```
