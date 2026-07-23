# Palette Accessibility Journal

This file contains CRITICAL accessibility and UX learnings only (e.g., screen reader edge cases, keyboard navigation).

## Entry Template
<!--
## YYYY-MM-DD - [Title]
**Learning:** [Insight]
**Action:** [How to apply next time]
-->

## 2024-05-19 - Align multi-line ParseError CLI output
**Learning:** Hardcoded spacing offsets in CLI error output can cause misalignment when dynamically generated content (like line numbers) increases in width.
**Action:** Calculate the width of dynamic line indicators using string methods (e.g., `line_number.to_s.size`) and use `rjust` or dynamic string building instead of hardcoding space lengths.
