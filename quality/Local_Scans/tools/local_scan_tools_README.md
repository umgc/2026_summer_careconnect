# CareConnect Local Scan Tools

This document describes the **static analysis tools used by the Local
Quality Gate (BN1)** in the CareConnect Quality & Security Enforcement
Subsystem.

These tools run **locally on the developer's machine before each
commit** to detect code quality issues early and prevent problematic
code from entering the repository.

## Tools Included in Local Scan

| Tool | Purpose | Language |
|------|---------|----------|
| Flutter Analyze | Static analysis for Flutter/Dart applications | Dart |
| Checkstyle | Enforces Java coding standards | Java |
| PMD | Detects maintainability issues and programming flaws | Java |
| SpotBugs | Detects bugs in compiled Java bytecode | Java |

# Flutter Analyze

## Purpose

Flutter Analyze performs static analysis on Dart code used in Flutter
applications.

It ensures that Dart code follows language rules and Flutter best
practices.

## Detects

-   Syntax errors
-   Type mismatches
-   Unused variables
-   Null safety violations
-   Linter rule violations

## Execution

The tool runs using:

    flutter analyze

Results are captured by the local scan script and included in the
unified HTML report.


# Checkstyle

## Purpose

Checkstyle enforces Java coding standards across the CareConnect
codebase.

It ensures consistency in formatting, naming conventions, and structural
organization.

## Detects

-   Incorrect indentation
-   Missing Javadoc
-   Naming convention violations
-   Unused imports
-   Line length violations
-   Code formatting inconsistencies

## Execution

    java -jar checkstyle-10.12.4-all.jar -c config.xml src/

Results are written to the analysis output directory and parsed into the
unified report.


# PMD

## Purpose

PMD analyzes Java source code for maintainability issues and potential
programming flaws.

It uses rule-based pattern matching to detect problematic code
structures.

## Detects

-   Unused variables and parameters
-   Duplicate code
-   Excessive cyclomatic complexity
-   Empty catch blocks
-   Performance issues
-   Potential bug patterns

## Execution

    pmd-bin-6.55.0/bin/run.sh pmd -d src

PMD results are captured and included in the unified quality report.


# SpotBugs

## Purpose

SpotBugs analyzes compiled Java bytecode to detect runtime bugs and
security issues.

Unlike source-based tools, SpotBugs inspects compiled `.class` files.

## Detects

-   Null pointer dereferences
-   Infinite recursion
-   Resource leaks
-   Incorrect synchronization
-   Security vulnerabilities

## Execution

    spotbugs -textui -xml target/classes

Results are written to the raw analysis artifacts and parsed into the
report.


# Local Scan Execution Flow

The local scan tools run through the local quality gate script:

    run-local-checks.sh

Execution pipeline:

    git commit
        ↓
    pre-commit hook
        ↓
    run-local-checks.sh
        ↓
    Flutter Analyze
    Checkstyle
    PMD
    SpotBugs
        ↓
    Generate HTML Report
        ↓
    Commit allowed or blocked


# Purpose of Local Tools

These tools provide early enforcement of:

-   Code quality standards
-   Maintainable code practices
-   Early bug detection
-   Consistent formatting and conventions

Running these checks locally reduces CI failures and improves developer
feedback speed.


Maintained by **Team D**
