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

## 2024-05-14 - Optimize `VersionReq#matches?` to eliminate repetitive regex
**Learning:** O(N) regex evaluation operations within tight resolver loops can be optimized by shifting the regex processing to the initialization phase.
**Action:** Shifted regex parsing from `Shards::Versions.matches_single_pattern?` to a new initialization field on `Shards::VersionReq` and a `parsed_patterns` Tuple(String, String, String?). The loop now uses a simple state check against the tuple conditions. This resulted in ~40% better IPS, decreasing operations from 3.36µs to 2.40µs, while dropping allocations from 1.27kB/op to 896B/op.
