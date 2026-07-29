# Palette Accessibility Journal

This file contains CRITICAL accessibility and UX learnings only (e.g., screen reader edge cases, keyboard navigation).

## Entry Template
<!--
## YYYY-MM-DD - [Title]
**Learning:** [Insight]
**Action:** [How to apply next time]
-->

## 2024-05-19 - Error Trace Line Number Alignment
**Learning:** Hardcoded formatting of line numbers (e.g. `#{line_number}. #{line}`) breaks visual alignment in CLI error traces when crossing 10, 100, etc. Furthermore, slicing lines arrays blindly can lead to `IndexError` when bounds are not clamped properly.
**Action:** Use `.rjust(max_len)` for multi-line display to dynamically right-align line numbers based on the largest line number length. Always calculate `to = {line_number, lines.size}.min` and `from = {to - 3, 0}.max` before slicing `lines[from...to]` for context previews.
