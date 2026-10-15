Act as a Technical Writer and Lead Developer. Generate a clear, structured Changelog from the provided [git diff / PR description / commit history].

Target Audience: [Select one: End Users / Internal Developers / Stakeholders]

Format Guidelines:
1. Follow Conventional Commits grouping standards:
   - Features (New functionality)
   - Bug Fixes (Fixes for existing issues)
   - Performance Improvements (Speed, memory, or efficiency gains)
   - Breaking Changes (Deprecations or incompatible API changes)
   - Maintenance & Internal (Refactoring, CI/CD, dependencies)
1. Entry Format: Use bullet points. Start each item with an imperative action verb (e.g., "Add", "Fix", "Update", "Remove").
2. For Breaking Changes: Highlight the old behaviour, the new behaviour, and a brief migration note.
3. Omit Noise: Filter out trivial commits (e.g., typos, merge conflict resolution, formatting changes) unless explicitly relevant.

Output Requirements:
- Title: Release version or date header (e.g., ## [v1.2.0] - YYYY-MM-DD)
- Summary: A 1-2 sentence executive summary of the release focus.
- Grouped Categories: Only include sections that have relevant changes.

Input Data:
```[diff / commits / pr_description]
[Paste git log, diff output, or pull request summary here]