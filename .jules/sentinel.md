# Sentinel Security Journal

This file contains CRITICAL security learnings only (e.g., unique vulnerability patterns, unexpected side effects).

## Entry Template
<!--
## YYYY-MM-DD - [Title] **Vulnerability:** [What you found] **Learning:** [Why it existed] **Prevention:** [How to avoid next time]
-->

## 2024-05-18 - Prevent path traversal in executable extraction
**Vulnerability:** A shard dependency could specify an `executable` path in `shard.yml` containing traversal elements like `../../../../etc/passwd`, causing shards to extract arbitrary files or write executables to unintended host directory locations when generating bin symlinks.
**Learning:** `Path#expand` combined with `Path#parents.includes?` provides an effective mechanism to canonicalize user-supplied paths and enforce that they stay within the intended extraction sandbox (`install_path`).
**Prevention:** Ensure any path strings derived from user configuration files (such as `shard.yml` configurations) that will be constructed into paths and acted upon by `File` or `FileUtils` methods are canonicalized and sandboxed.
