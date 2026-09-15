# Pause Icon Color Design

## Goal

Replace the system-rendered blue pause Emoji with a monochrome pause mark that belongs to the app's warm wood palette.

## Decision

The pause mark is drawn with two ArkUI bars inside the existing button. The light theme uses `DesignTokens.wood` (`#8A5635`) and the dark theme uses `DesignTokens.accentDark` (`#C29961`). The label uses the same color, while the current warm neutral button background remains unchanged.

This is preferred over a PNG because it stays crisp at every density, and over a system symbol because the project's current API and icon conventions do not establish a tested symbol resource path. It also avoids Emoji presentation entirely.

## Scope

- Change only the running auto-session pause button presentation.
- Preserve pause/resume behavior, button dimensions, touch handling, and accessibility text.
- Keep the resumed-state button unchanged.
- Add a static regression check that rejects the pause Emoji and requires the custom mark.

## Verification

- Run the focused static regression check and project standard check.
- Build debug, ohosTest, and release artifacts.
- Verify on the available phone target; tablet and 2in1 remain blocked when no targets are connected.
