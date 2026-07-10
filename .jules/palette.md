# Palette Accessibility Journal

This file contains CRITICAL accessibility and UX learnings only (e.g., screen reader edge cases, keyboard navigation).

## Entry Template
<!--
## YYYY-MM-DD - [Title]
**Learning:** [Insight]
**Action:** [How to apply next time]
-->

## 2024-05-14 - Respecting Terminal Output
**Learning:** CLI utilities like `shards outdated` pipe their outputs often, and hardcoded ANSI escape sequences can pollute the output if the terminal does not support colors or it is piped to a file.
**Action:** When applying colors and formatting using the `Colorize` module, use `.toggle(Shards.colors?)` on the resulting `Colorize::Object` so it handles standard piped outputs and `--no-color` arguments gracefully.
