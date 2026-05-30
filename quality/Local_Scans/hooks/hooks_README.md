# Git Hooks -- Local Quality Gate Integration

## Overview

The `hooks/` directory contains the Git hook scripts used to trigger the
**Local Quality Gate (BN1)** before code is committed.

These hooks integrate static analysis directly into the developer
workflow to prevent commits that violate project quality or security
standards.

The hooks are installed by configuring Git to use this directory as the
repository hook path.


## Hook Provided

| Hook | Purpose |
|------|---------|
| pre-commit | Runs the local quality gate before every commit |


## Installation

After cloning the repository, configure Git to use the project hook
path:

``` bash
git config core.hooksPath quality/Local_Scans/hooks
```

This tells Git to execute the hooks stored in this directory.


## Pre‑Commit Hook Behavior

The `pre-commit` hook:

1.  Locates the repository root
2.  Executes the local quality gate script
3.  Blocks the commit if violations are detected

Execution flow:

    git commit
       ↓
    pre-commit hook
       ↓
    run-local-checks.sh
       ↓
    Static analysis tools execute
       ↓
    Commit allowed or blocked


## Failure Behavior

If a quality check fails, the commit is blocked and the developer will
see:

    ❌ Commit blocked – fix the issues above before committing.

Developers must resolve the issues before committing again.


## Emergency Bypass

In rare situations the gate may be bypassed:

    git commit --no-verify

This should be used sparingly because the **CI Quality Gate will still
run during pull request validation**.


## Purpose

The hook layer ensures:

-   Early detection of code issues
-   Faster developer feedback
-   Reduced CI pipeline failures
-   Consistent enforcement across the team
