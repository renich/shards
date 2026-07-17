# Palette Accessibility Journal

This file contains CRITICAL accessibility and UX learnings only (e.g., screen reader edge cases, keyboard navigation).

## Entry Template
<!--
## YYYY-MM-DD - [Title]
**Learning:** [Insight]
**Action:** [How to apply next time]
-->
## 2026-07-17 - Error Alignment and Color Pipeline Output\n**Learning:** Crystal's default 'colorize' disables itself if the stdout is not a TTY. But sometimes, when color output is explicitly forced by the tool's config, they will not be respected when piping. Also, hardcoding arrow spaces like `"     "` for line number pointers will lead to misalignment for double digit or larger line numbers.\n**Action:** Use `.toggle(Shards.colors?)` on Colorize instances to ensure explicit configuration overrides default TTY behaviors. Right padding with calculated width `rjust(line_number.to_s.size)` solves line numbering misalignment bugs.
