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
\n## 2026-07-13 - Pre-parse conditions in VersionReq to avoid Regex during resolution\n**Learning:** Regex evaluations inside  were a severe bottleneck in requirement comparisons. Moving these to  inside a  record significantly boosts matching speed (~3x IPS boost in benchmarks) and saves memory allocations.\n**Action:** Avoid allocating and evaluating regular expressions inside loops or frequently called query methods. Instead, eagerly parse into descriptive objects/enums during initialization.

## 2024-05-14 - Pre-parse conditions in VersionReq to avoid Regex during resolution
**Learning:** Regex evaluations inside `matches_single_pattern?` were a severe bottleneck in requirement comparisons. Moving these to `VersionReq#initialize` inside a `Condition` record significantly boosts matching speed (~3x IPS boost in benchmarks) and saves memory allocations.
**Action:** Avoid allocating and evaluating regular expressions inside loops or frequently called query methods. Instead, eagerly parse into descriptive objects/enums during initialization.
