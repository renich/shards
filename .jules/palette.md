# Palette Accessibility Journal

This file contains CRITICAL accessibility and UX learnings only (e.g., screen reader edge cases, keyboard navigation).

## Entry Template
<!--
## YYYY-MM-DD - [Title]
**Learning:** [Insight]
**Action:** [How to apply next time]
-->

## $(date +%Y-%m-%d) - Graceful Color Degradation and CLI Alignment
**Learning:** `Colorize.on_tty_only!` is deprecated since Crystal 1.17 because it is the default behavior. For manually checking/setting colorization state based on TTY presence, `Colorize.default_enabled?(STDOUT, STDERR)` must be used. Additionally, CLI error messages containing dynamically numbered lines require manual right-alignment and careful caret (`^`) positioning based on the max line number width, rather than hardcoded spaces.
**Action:** Use `.toggle(Shards.colors?)` on `.colorize(:color)` chains to ensure colors are gracefully degraded when piping CLI output, and use `.to_s.rjust(max_len)` for aligned line numbering in multiline error traces.
