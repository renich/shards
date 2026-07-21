# Sentinel Security Journal

This file contains CRITICAL security learnings only (e.g., unique vulnerability patterns, unexpected side effects).

## Entry Template
<!--
## YYYY-MM-DD - [Title] **Vulnerability:** [What you found] **Learning:** [Why it existed] **Prevention:** [How to avoid next time]
-->
## YYYY-MM-DD - Path Traversal in Package Name **Vulnerability:** Shards::Package#install_path allowed path traversal sequences like  in package names, escaping the sandbox directory. **Learning:** Unvalidated inputs constructed into file paths can escape sandboxes even if the base path is absolute. **Prevention:** Always canonicalize user-supplied components with  and verify they still reside within the base sandbox directory (accounting for platform-specific path separators).
## 2024-05-24 - Path Traversal in Package Name **Vulnerability:** Shards::Package#install_path allowed path traversal sequences like `../../../` in package names, escaping the sandbox directory. **Learning:** Unvalidated inputs constructed into file paths can escape sandboxes even if the base path is absolute. **Prevention:** Always canonicalize user-supplied components with `Path#expand` and verify they still reside within the base sandbox directory (accounting for platform-specific path separators).
