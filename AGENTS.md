# Shards Package Manager Development Guidelines for AI Agents

Welcome! This document serves as a generalized reference for AI agents collaborating on the [crystal-lang/shards](file:///home/renich/src/crystal/shards) repository.

### 🎯 Project Vision & Context
- **Testing Sandbox**: This repository (`renich/shards`) is a sandbox environment specifically set up to test, evaluate, and benchmark the capabilities of Google's **Jules** coding agent on the Shards package manager.
- **Upstream Appeal**: Our long-term goal is to maintain, harden, and optimize this codebase to such an exceptional standard of safety, performance, and style that our contributions will eventually be highly appealing to the upstream maintainers. Focus heavily on absolute correctness, exhaustive specs, and meticulous documentation.

---

## 🛑 General Mandates & Workflow

### Deterministic Collaboration Protocol (DCP)
Based on the principles outlined in ["Collaboration in the age of AI"](https://forum.crystal-lang.org/t/collaboration-in-the-age-of-ai/9051), all development work must follow this strict three-phase process to eliminate AI-generated review fatigue, prevent workspace pollution, and avoid using maintainers as human compilers:
1. **Context Before Code (The Consensus Engine)**: Before modifying any code, ingest the relevant module's commit history, closed PRs, and rejected architectural designs. Understand *why* the codebase is currently structured this way, and synthesize the architectural consensus to route around historical landmines.
2. **Invariants First (The Adversarial Shift)**: Never submit full implementations to see what sticks. First, write an isolated, failing spec or benchmark that mathematically proves the existence of the bug, performance issue, or security flaw. Once the human reviewer agrees the test boundaries are valid and the spec *should* pass, proceed to submit the minimal fix.
3. **Strict Ecosystem Compliance (Zero-Friction Integration)**: Treat codebase conventions as rigid APIs. Ensure all changes comply 100% with the repository layout, formatting (`crystal tool format`), lint rules (`ameba`), and testing macros. Workspace pollution (e.g. leftover diff patches, execution logs, binary artifacts) is strictly forbidden. Align pull requests with the maintainer's operational cadence.

### Project Journaling Protocol (PJP)
- **Journal Location**: Historical engineering decisions, findings, and whiteboard state are stored inside the `.agents/` directory.
- **PJP Standard**: To understand the journal entries and the toolset, see the [PJP Project Documentation](https://gitlab.com/renich/pjp).

### Git Hygiene & Commit Standards
- **Track AI Configurations**: Track `.agents/` and `.jules/` in Git so that cloud-based agents (like Jules) can fetch the PJP journal database and persist their own critical learning journals between sessions.
- **Clean Commits**: Never commit credentials or local build artifacts (e.g. build binaries, object files).
- **Conventional Commits**: Format commit messages according to Conventional Commits standards (e.g. `feat(parser): ...`, `fix(resolver): ...`, `perf(solver): ...`).
- **Co-Author & Signing**: Include contribution metadata in the commit footer:
  - `Co-developed-by: Gemini AI <renich+gemini@woralelandia.com>`
  - `Signed-off-by: Rénich Bon Ćirić <renich@woralelandia.com>`

### Agent & PR Hygiene
- **Duplicate PR Prevention**: Before initiating any work or creating a new branch, query GitHub via `gh pr list --search "title/topic"` to search for existing open or closed pull requests dealing with the same issue or feature. If an existing PR exists, you MUST reuse and update its branch instead of spawning a new one.
- **Platform-Specific Logic**: When implementing path or filesystem safety checks, determine if the behavior differs across operating systems. Restrict platform-specific checks (such as backslash `\` validation) to Windows systems using compile-time flags (e.g., `{% if flag?(:win32) %}`) to avoid breaking Unix environments where those characters are valid.
- **Strict Branch Naming (Deduplication)**: You must use a predictable, reusable branch naming convention structured as `jules/task-[task_id]` (e.g., `jules/task-1277355`). Pushing commits to this specific branch will automatically update the existing open pull request on GitHub, preventing the creation of duplicate PRs.
- **Upstream Alignment**: If the upstream master branch has advanced since the task branch was created, fetch `upstream` and rebase your working branch (`git pull --rebase upstream master`) before testing and submitting. This ensures changes remain fully compatible with the latest upstream state and prevents merge conflicts.
- **PR Feedback & Iteration**: When responding to human feedback or review comments on a pull request, read the comments carefully. Prioritize reproducing any reported compilation errors or spec failures, make targeted changes on the same branch to address the review comments, and push the updates. Do not create new branches or close/re-open pull requests during iteration.
- **Adversarial Review**: All pull requests must undergo a pedantic, adversarial code review simulating a strict reliability and security gatekeeper. The review must actively search for unhandled exceptions, race conditions, edge cases, style issues, and test omissions, producing a structured list of findings and a clear `APPROVE` or `REJECT` verdict.

### 🕵️‍♂️ Two-Stage Code Review Pipeline (Adversarial & Moderator)
All code submissions or pull requests under review must undergo a two-stage sequential review pipeline. When acting as a reviewer, you must execute and document both stages:

#### Stage 1: The Ruthless Adversarial Reviewer (Flaw Hunter)
- **Persona & Tone**: Extremely pedantic, strict, and aggressive. Your sole purpose is to find every single flaw—from the most massive security and performance bugs to the most subtle, insignificant styling, micro-optimization, or logic edge cases.
- **Mindset**: Assume the code is fundamentally flawed and it is your job to find every possible issue.
- **Directive**: Scrutinize code for off-by-one errors, solver bottlenecks, type-narrowing leaks, missing specs, naming quirks, and performance regressions.

#### Stage 2: The Moderate Reviewer (Sanity & Hallucination Filter)
- **Persona & Tone**: Pragmatic, rational, and balanced. Your goal is to review the findings generated in Stage 1 and cross-examine them.
- **Mindset**: Verify that the Ruthless Reviewer's findings are actual issues, filtering out false positives or hallucinations caused by over-scrutiny.
- **Directive**:
  - Filter out invalid findings (e.g. where the compiler already guarantees type safety, where the behavior is intended, or where the standard library handles it).
  - Verify that code changes recommended by Stage 1 are actually valid and do not cause regressions.
  - Compile the final, filtered list of **Verified Findings** (Critical, Major, Minor).
  - Output the final verdict: `APPROVE` (only if the code is flawless and fully covered by specs) or `REJECT` (if any warnings/errors exist).

---

## 🛠 Repository Workflows & Testing

### Compilation & Prerequisites
Building and testing Shards requires `crystal` and development libraries for version control systems used in specs:
- Install packages: `gnumake`, `asciidoctor`, `git`, `mercurial` (`hg`), and `fossil`.
- **Container-Based Testing**: If local dependencies are missing, commands can be run inside the official Crystal container (e.g. `podman run --rm -v .:/workspace:z -w /workspace crystallang/crystal:latest-alpine make test`).

### Executing Specs & Testing
Run the appropriate make targets for validation:
- `make build` - Compile the shards binary.
- `make test` - Run the entire test suite.
- `make test skip_fossil=1` - Run the test suite skipping fossil tests.

> [!TIP]
> To execute targeted spec files directly, compile first and run: `bin/crystal spec spec/path/to/spec_file.cr`.

### Verification & Performance (Pre-Commit / Benchmarks)
- **Pre-Commit Verification**: Before submitting a PR or declaring a task done, run the pre-commit git-hooks using `devenv shell` or `pre-commit run --all-files` to ensure syntax, styling, and formatting constraints are satisfied.
- **Performance Benchmarking (Bolt)**: For any performance optimization tasks (Bolt), write and run a benchmarking script (using standard `Benchmark`) comparing the old vs. new logic. Compile the benchmark in release mode (`-Drelease`) and document the performance metrics (IPS speedups, memory reallocations saved) in the pull request description.

---

## 🧹 Code Quality & Style Standards (Ameba)

Strictly adhere to Crystal's idiomatic conventions enforced by the linter:
- **Query / Boolean Methods**: Methods and properties returning a boolean must end with a question mark (e.g. `def active? : Bool`).
- **Guard Clauses**: Use guard clauses (`return unless x`) to avoid wrapping entire method bodies in `if` statements.
- **Complexity**: Keep methods under 40 lines. Extract deeply nested conditional blocks into private helper methods.

---

## ⚡️ Statically Typed & Compiled Safety Rules

### Nil Safety & Type Narrowing
> [!WARNING]
> Never use `.not_nil!` to silence the compiler.

Use type narrowing techniques (`if`, `case`, `try`, or `.as?`) to handle union and optional types safely.

### Process Spawning Safety
- Always spawn commands using array-based arguments (`Process.run("cmd", ["arg1", "arg2"])`) to prevent shell injection.
- Handle parsed content (JSON, YAML, TOML) inside rescue blocks to process format errors safely.
