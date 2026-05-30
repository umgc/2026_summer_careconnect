# CareConnect CI Quality Gate Engine

## Overview

his directory contains the CI Quality Gate Engine for CareConnect. The gate engine runs automatically on every push and pull request to team_d and team_d-* branches. It executes 13 static analysis, security, and vulnerability scanning tools, evaluates results against a centralized policy, and enforces merge decisions via GitHub Actions exit codes. No manual intervention is required to trigger the pipeline.

---

## Pipeline Architecture

The gate engine follows a strict four-stage pipeline. Each stage has a single
responsibility and produces a well-defined output consumed by the next stage.

```
Workflow (GitHub Actions)
        │
        ▼
Stage 1 — Tool Execution
  Each tool runs independently and writes its native output to:
  quality/analysis/raw/
        │
        ▼
Stage 2 — Normalization  (normalize.py)
  All raw artifacts are parsed by tool-specific parsers and
  converted into a unified schema:
  quality/analysis/normalized/normalized.json
        │
        ▼
Stage 3 — Policy Evaluation  (policy_engine.py)
  Normalized results are evaluated against policy.yaml.
  Each tool receives a pass/fail decision:
  quality/analysis/evaluated/evaluated.json
        │
        ▼
Stage 4 — Reporting  (report/report.py)
  Evaluated results are rendered into:
  quality/analysis/report.md    — GitHub Actions Job Summary
  quality/analysis/report.html  — Full interactive HTML report
```

No pass/fail logic lives in the workflow. The gate engine owns all enforcement.
No report rendering lives in the workflow. The report package owns all reporting.

---

## Tool Inventory

| Tool | Category | Language | Blocks Merge | Fail Condition |
|------|----------|----------|-------------|----------------|
| trufflehog | Secrets Scan | All | Yes | Any finding |
| gitleaks | Secrets Scan | All | Yes | Any finding |
| flutter_analyze | SAST — Flutter | Dart | Yes | Any error |
| checkstyle | SAST — Java | Java | Yes | Any violation |
| pmd | SAST — Java | Java | Yes | Medium and above |
| spotbugs | SAST — Java | Java | Yes | Medium and above |
| semgrep | SAST — Multi | All | Yes | High and above |
| pylint | SAST — Python | Python | Yes | High and above |
| bandit | SAST — Python | Python | Yes | Medium and above |
| htmlhint | SAST — Web | HTML | Yes | Any violation |
| stylelint | SAST — Web | CSS/SCSS | Yes | Any violation |
| dependency_check | SCA — Multi | All | Yes | Any vulnerability |
| trivy | SCA — Container | All | Yes | Medium and above |

All 13 tools are currently enforced. A violation in any tool will block the merge
once branch protection is enabled.

---

## Viewing Results

**Option 1 — GitHub Actions**
Navigate to the repository on GitHub and click the **Actions** tab. Select the most
recent **Build and Analyze** workflow run. Once the workflow completes, click on the
workflow run to open it. At the top of the page you will find the
**CareConnect Quality Gate Report** — a summary of all tool results, policy decisions,
and the overall merge status for that run.

**Option 2 — Pull Request Checks**
When a pull request is opened, the gate engine runs automatically as a required check.
The check status is displayed directly on the pull request page, and the full report
is posted as a comment on the PR.

> **Note:** Branch protection enforcement is currently disabled while known violations
> across the codebase are being resolved. Once the codebase reaches a passing state,
> branch protection will be enabled and merges will be blocked until all required
> checks pass.

---

## Download the Artifact Bundle

Scroll to the bottom of the workflow run page. Under **Artifacts**, click the download
button to download the artifact bundle as a ZIP file. Extract the ZIP to view the
full analysis output.

---

## Artifact Bundle Contents

```
quality/analysis/
├── raw/           Native tool outputs (evidence layer)
├── normalized/    normalized.json — unified schema
├── evaluated/     evaluated.json — policy decisions
├── report.md      Markdown report (GitHub Actions Job Summary)
└── report.html    Full interactive HTML report
```

**raw/**
Contains the native output from each scanning tool in its original format. These files
are the unmodified evidence layer — the source of truth for every finding reported by
the gate engine.

**normalized/**
Contains `normalized.json` — a single unified file produced by the normalization layer.
All tool outputs, regardless of their native format (XML, JSON, or JSONL), have been
converted into a consistent schema. This allows the policy engine to evaluate every
tool result in the same way without tool-specific logic.

**evaluated/**
Contains `evaluated.json` — the output of the policy engine. This file records the
policy decision for each tool: whether a violation occurred, whether the tool is
blocking or advisory, the reason for the decision, and the overall merge outcome.

**report.md**
The Markdown version of the quality gate report. This is the same report displayed on
the GitHub Actions Job Summary page. It provides a concise overview of all tool results,
violation counts, severity levels, and the final merge decision.

**report.html**
A fully self-contained, human-readable HTML report with all results organized by tool
category. Each tool section includes finding details such as file, line number,
severity, rule, and message. The report includes interactive filtering, tool visibility
toggles, and search to help triage large volumes of findings.

---

## Report Filtering

The HTML report includes a built-in filter bar between the Legend and the Tool Results
Summary table. All filtering is client-side — no server or network connection required.

### Severity Filter
A dropdown that limits visible findings to a selected severity threshold.

| Option | Shows |
|--------|-------|
| All | Every finding regardless of severity |
| Critical only | Critical findings only |
| High and above | High and Critical |
| Medium and above | Medium, High, and Critical |
| Low and above | Low, Medium, High, and Critical |

### Tool Visibility Toggle
Each tool in the Tool Results Summary table has a toggle in the **Show** column.
Turning a tool OFF hides its entire findings section and excludes it from search and
severity filtering. Turning it back ON restores the section and re-applies active filters.

> Manually hidden tools are not restored by clearing the search — only the
> **Reset** button restores all toggles.

### Search Bar
A text input that filters finding rows in real time across all visible tool sections.
Matches against file path, rule name, and message. Case insensitive. A **Clear** button
beside the input clears the search term instantly.

### Combining Filters
All three filters apply simultaneously using AND logic. A finding row is visible only
when it passes the severity threshold, matches the search term, and belongs to a
toggled-ON tool section.

### Reset
The **Reset** button restores all defaults — all toggles ON, severity set to All,
search bar cleared.

---

## Policy Configuration

All enforcement rules are defined in `quality/ci/gate/policy.yaml`. This is the single
file that controls which tools block merges, what thresholds trigger a violation, and
whether a tool is active. Enforcement behavior can be changed by editing this file —
no code changes are required.

### Gate Mode

```yaml
gate:
  mode: enforce
```

| Mode | Behavior |
|------|----------|
| `enforce` | Gate exits with failure on violations — blocks CI |
| `report_only` | Gate reports violations but never fails CI |

### Tool Entry Structure

```yaml
tools:
  trufflehog:
    blocking: true
    description: "TruffleHog (Secrets Scan)"
    fail_on:
      any_finding: true
```

| Field | Purpose |
|-------|---------|
| `blocking` | Whether violations from this tool block the merge |
| `description` | Human-readable label used in reports |
| `fail_on` | Condition that constitutes a policy violation |

### Fail Condition Types

| Condition | Example | Meaning |
|-----------|---------|---------|
| `any_finding` | `any_finding: true` | Any output from the tool is a violation |
| `any_vulnerability` | `any_vulnerability: true` | Any CVE finding is a violation |
| `violation_count` | `violation_count: ">0"` | Any violation count above zero |
| `error_count` | `error_count: ">0"` | Any error count above zero |
| `severity` | `severity: "medium_and_above"` | Findings at or above the threshold |

---

## Adding a New Tool

To add a new scanning tool to the pipeline:

1. Write a parser under `quality/ci/gate/parsers/`
2. Register it in `quality/ci/gate/normalize.py`
3. Add a policy entry in `quality/ci/gate/policy.yaml`
4. Add the tool's category to `quality/ci/gate/report/report_constants.py`
5. Add the workflow step to `.github/workflows/build-and-analyze.yml`

No changes to the gate engine, policy engine, or reporting layer are required.

### Parser Contract

Every parser must return a normalized dict conforming to this structure:

```python
{
    "tool": "tool_name",
    "executed": True,
    "artifact_present": True,
    "runtime_error": False,
    "violation_count": 0,
    "findings": [],
    "severity_counts": {
        "critical": 0,
        "high": 0,
        "medium": 0,
        "low": 0,
        "info": 0,
    },
    "metadata": {},
}
```

---

## Environment Variables and Secrets

| Secret | Purpose | Where to Set | Effect if Missing |
|--------|---------|-------------|------------------|
| `NVD_API_KEY` | OWASP Dependency-Check NVD database | GitHub → Settings → Secrets → Actions | dependency_check runs without API key — slower, rate limited |
| `GITHUB_TOKEN` | PR comment posting | Automatically provided by GitHub Actions | Report comment not posted to PR |

To add `NVD_API_KEY`: GitHub repository → **Settings** → **Secrets and variables** →
**Actions** → **New repository secret** → Name: `NVD_API_KEY`.

---

## Troubleshooting

**Gate engine exits with runtime error**
Check the workflow log for the `Run Gate Engine` step. The most common cause is a
malformed raw artifact. Inspect `quality/analysis/raw/` in the artifact bundle to
identify which tool produced unexpected output.

**Tool shows DISABLED in report**
The tool's raw artifact was not found in `quality/analysis/raw/`. Check the workflow
log for that tool's step to see if it was skipped or produced an error.

**Tool shows SUCCESS but finding count is zero unexpectedly**
The parser may have received an empty or malformed artifact. Download the artifact
bundle and inspect the raw file for that tool.

**PR comment not posted**
Verify `GITHUB_TOKEN` permissions include `pull-requests: write`. Check the
`Post PR Comment` step in the workflow log.

**dependency_check is slow or failing**
The NVD API key may be missing or invalid. Without a key, NVD rate-limits downloads.
Add `NVD_API_KEY` to repository secrets. See Environment Variables section above.

**Workflow triggered on wrong branches**
Check the `on:` trigger block in `.github/workflows/build-and-analyze.yml`. The gate
runs on `team_d` and `team_d-*` branches only.

---

## Directory Structure

```
quality/ci/gate/
├── parsers/                    One parser per tool
│   ├── bandit.py
│   ├── checkstyle.py
│   ├── dependency_check.py
│   ├── flutter.py
│   ├── gitleaks.py
│   ├── htmlhint.py
│   ├── pmd.py
│   ├── pylint.py
│   ├── semgrep.py
│   ├── spotbugs.py
│   ├── stylelint.py
│   ├── trivy.py
│   └── trufflehog.py
├── report/                     Report rendering package
│   ├── render_report/          Modular HTML report builder
│   │   ├── __init__.py
│   │   ├── report_builder.py   Main assembly — entry point
│   │   ├── report_blocks.py    Banner, header, PR block, summary
│   │   ├── report_sections.py  Tool detail sections and findings tables
│   │   ├── report_rows.py      Finding rows and summary table rows
│   │   ├── report_badges.py    Severity badges, pills, status indicators
│   │   ├── report_controls.py  Filter bar and legend block HTML
│   │   ├── report_scripts.py   Client-side JavaScript filtering logic
│   │   └── report_styles.py    CSS styles
│   ├── __init__.py
│   ├── report.py               Report orchestrator
│   ├── report_constants.py     CATEGORY_MAP and SEVERITY_COLORS
│   ├── report_github.py        GitHub PR comment renderer
│   ├── report_html.py          Shim — delegates to render_report
│   └── report_md.py            Markdown report renderer
├── __init__.py
├── gate.py                     Gate engine entry point and exit code logic
├── humanize.py                 Human-readable severity and label helpers
├── normalize.py                Normalization orchestrator
├── policy_engine.py            Policy evaluation engine
├── policy.yaml                 Enforcement policy — edit to change rules
├── README.md                   This file
├── schemas.py                  Normalized schema definitions
└── utils.py                    Shared utilities
```

To modify report appearance, edit `render_report/report_styles.py`.
To modify filtering behavior, edit `render_report/report_scripts.py`.
To modify layout or structure, edit `render_report/report_builder.py`.
To change enforcement rules, edit `policy.yaml`.
No other files need to change for cosmetic, behavioral, or policy updates.

---
