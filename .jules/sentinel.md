# Sentinel Security Journal

This file contains CRITICAL security learnings only (e.g., unique vulnerability patterns, unexpected side effects).

## Entry Template
<!--
## YYYY-MM-DD - [Title] **Vulnerability:** [What you found] **Learning:** [Why it existed] **Prevention:** [How to avoid next time]
-->

## 2024-05-27 - 🛡️ Sentinel: Improve path resolution safety for executables
**Vulnerability:** Path Traversal
**Learning:** Found path traversal vulnerability in `find_executable_file` in `src/package.cr`. The method allowed executables to be resolved outside the install directory if `name` contained `../` segments (e.g., `../../../etc/passwd`).
**Prevention:** Ensure we use `.expand` on both the resolved file path and the base install path, and verify that the file path still starts with the expanded base install path, carefully appending directory separators to avoid matching sibling directories.
