# Palette Accessibility Journal

This file contains CRITICAL accessibility and UX learnings only (e.g., screen reader edge cases, keyboard navigation).

## Entry Template
<!--
## YYYY-MM-DD - [Title]
**Learning:** [Insight]
**Action:** [How to apply next time]
-->

## 2024-05-18 - Fix ParseError output alignment in src/errors.cr
**Learning:** When displaying file lines for error context in Crystal (e.g., `lines[from...to]`), bound the line indices using `{line_number, lines.size}.min` and `{to - 3, 0}.max` to prevent `IndexError` on out-of-bounds line references. To dynamically align the caret (`^`), base the spacing on `to.to_s.size`.
**Action:** Always bound array indices dynamically rather than relying on assumed file lengths, and avoid hardcoding spacing padding to support dynamic text widths.
