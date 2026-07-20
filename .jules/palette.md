# Palette Accessibility Journal

This file contains CRITICAL accessibility and UX learnings only (e.g., screen reader edge cases, keyboard navigation).

## Entry Template
<!--
## YYYY-MM-DD - [Title]
**Learning:** [Insight]
**Action:** [How to apply next time]
-->

## $(date +%Y-%m-%d) - Fix Colorize configuration warning
**Learning:** Crystal 1.17 removed `Colorize.on_tty_only!` and made it default behavior.
**Action:** Replace `Colorize.on_tty_only!` with `Colorize.default_enabled?(STDOUT, STDERR)`. Also make sure all output `Colorize` usages have a `.toggle(Shards.colors?)` to respect the global color config and piped targets.
