# Bolt Performance Journal

This file contains CRITICAL performance learnings only (e.g., unique bottlenecks, optimizations that didn't work).

## Entry Template
<!--
## YYYY-MM-DD - [Title]
**Learning:** [Insight]
**Action:** [How to apply next time]
-->

## 2024-05-14 - Cache requirement parsing for fast matches
**Learning:** Requirements patterns inside `Shards::VersionReq` were parsed via Regex inside `#matches?`, causing a loop that executes regex comparisons millions of times during resolution. We discovered that by pre-parsing requirements during initialization and caching them inside tuples, IPS improved by ~35% and memory allocations reduced substantially.
**Action:** Always look for O(N) regex evaluation operations within tight resolver loops. If the structure doesn't change, shift the regex processing to the initialization phase and cache the extracted data in strict structs or tuples.
