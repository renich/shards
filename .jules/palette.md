# Palette Accessibility Journal

This file contains CRITICAL accessibility and UX learnings only (e.g., screen reader edge cases, keyboard navigation).

## Entry Template
<!--
## YYYY-MM-DD - [Title]
**Learning:** [Insight]
**Action:** [How to apply next time]
-->
## YYYY-MM-DD - Colorize Deprecation & Toggle
**Learning:** In Crystal 1.17+, Colorize.on_tty_only! is deprecated. Replace it with Colorize.enabled = Colorize.default_enabled?(STDOUT, STDERR).
**Action:** Ensure any CLI colorized text appropriately calls `.toggle(Shards.colors?)` so that piping output degrading gracefully does not hardcode ANSI values.
