# Static Analysis Checks

## Overview

The `checks/` directory contains the scripts that execute the individual
static analysis tools used by the **Local Quality Gate (BN1)**.

Each script is responsible for running a specific tool, capturing its
output, and writing the results to the unified analysis artifact
directory.


## Check Scripts

| Script | Tool | Purpose |
|-------|------|---------|
| check_flutter.sh | Flutter Analyze | Dart and Flutter static analysis |
| check_checkstyle.sh | Checkstyle | Java coding standard enforcement |
| check_pmd.sh | PMD | Java source code analysis |
| check_spotbugs.sh | SpotBugs | Java bytecode bug detection |


## Execution Flow

The scripts are orchestrated by:

    run-local-checks.sh

Execution sequence:

    run-local-checks.sh
          ↓
    check_flutter.sh
    check_checkstyle.sh
    check_pmd.sh
    check_spotbugs.sh

Each script:

1.  Runs the tool
2.  Captures the output
3.  Writes results to the analysis directory
4.  Returns an exit code


## Exit Codes

| Code | Meaning |
|------|--------|
| 0 | Check passed |
| 1 | Violations detected |

If any script returns a failure code, the **local gate blocks the commit**.

## Output Location

All tool results are written to:

    quality/analysis/raw/

These results are then parsed and included in the unified HTML report.


## Design Principles

Check scripts must:

-   Be deterministic
-   Produce machine-readable output
-   Return proper exit codes
-   Write outputs to the analysis artifact directory

Scripts should avoid modifying source files and must remain **read-only
analysis tools**.
