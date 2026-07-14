# Sentinel Security Journal

This file contains CRITICAL security learnings only (e.g., unique vulnerability patterns, unexpected side effects).

## Entry Template
<!--
## YYYY-MM-DD - [Title] **Vulnerability:** [What you found] **Learning:** [Why it existed] **Prevention:** [How to avoid next time]
-->
## 2024-05-29 - Path Traversal in Package Installation Directory
**Vulnerability:** Path traversal vulnerability existed in `Shards::Package#install_path` due to user-supplied dependency names being directly joined to the base installation path without canonicalization.
**Learning:** A malicious package could define a name like `../../foo` causing it to install outside of the intended `lib/` directory sandbox.
**Prevention:** Always use `Path#expand` to canonicalize both the target path and the base sandbox path. Ensure the canonical target path starts with the canonical base path + directory separator (accounting for Windows via `{% if flag?(:win32) %}`).
