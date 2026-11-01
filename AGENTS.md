
# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```text
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

## ASDF plugin for installing zoxide

This project is a plugin for ASDF that installs [zoxide](https://github.com/ajeetdsouza/zoxide).

zoxide is a single static binary. Unlike tools that ship one portable file, every release has a separate
tarball per platform, named `zoxide-<version>-<target>.tar.gz` (from 0.8.2 on), for example
`zoxide-0.10.0-x86_64-unknown-linux-musl.tar.gz`. The tarball contains the `zoxide` binary, `man/man1/*.1`
and `completions/`.

Releases are published at [https://github.com/ajeetdsouza/zoxide/releases]

The official install script is saved in [zoxide-install.sh](docs/zoxide-install.sh). Use its
`get_architecture()` function as the reference for mapping `uname` output to a release target.

Verify installation

```shell
zoxide --version
```

Run `scripts/docker-test.bash` to test the plugin scripts on several architectures in Docker.

## Read the ASDF documentation

Read the file [create.md](docs/create.md) when asked about implementing this plugin

Update the root README.md when making changes in this repo

Use shfmt and shellcheck when making changes.
