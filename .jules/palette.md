# Palette Accessibility Journal

This file contains CRITICAL accessibility and UX learnings only (e.g., screen reader edge cases, keyboard navigation).

## Entry Template
<!--
## YYYY-MM-DD - [Title]
**Learning:** [Insight]
**Action:** [How to apply next time]
-->
## 2026-07-18 - Graceful CLI colorization degradation in Shards
**Learning:** When applying colors to CLI outputs using Crystal's `Colorize` module, missing `.toggle(Shards.colors?)` can cause escape codes to leak when users provide the `--no-color` flag or pipe output. Moreover, `Colorize.on_tty_only!` is deprecated in Crystal 1.17+ and replacing it with `Colorize.enabled = Colorize.default_enabled?(STDOUT, STDERR)` avoids warnings.
**Action:** Use version-aware conditional macros to invoke `Colorize.default_enabled?(STDOUT, STDERR)` for Crystal >= 1.17.0, and always append `.toggle(condition)` to colorized strings to ensure formatting degrades cleanly.
