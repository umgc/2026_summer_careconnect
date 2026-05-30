# Quality Report Engine

## Overview

The `report/` directory contains the Python reporting engine used to
generate the **Local Quality Gate HTML report**.

The report engine aggregates outputs from all static analysis tools and
renders a unified report for developers.

This report allows developers to quickly review findings across tools in
a single interface.


## Components

| File | Purpose |
|------|---------|
| generate_report.py | Main report generation entry point |
| report_parsers.py | Parses tool outputs into structured data |
| report_html.py | Generates the final HTML report |
| open_report.py | Opens the generated report in the browser |
| render_report/ | HTML templates and rendering utilities |


## Report Generation Flow

    Static Analysis Tools
            ↓
    Raw Tool Output
            ↓
    report_parsers.py
            ↓
    Structured Data Model
            ↓
    report_html.py
            ↓
    HTML Report Generated


## Generated Artifacts

Reports are written to:

    quality/analysis/local/

Example structure:

    quality/analysis/local/
    ├── report.html
    ├── report.json
    └── report.zip


## HTML Report Features

The generated report includes:

-   Tool-by-tool findings
-   Severity breakdowns
-   File locations for issues
-   Interactive filtering
-   Summary metrics


## Developer Workflow

After running the local quality gate:

    run-local-checks.sh

Developers can open the report:

    python open_report.py

This launches the report in the default browser.


## Purpose

The report engine provides:

-   Clear visibility into quality issues
-   Consistent reporting format with CI reports
-   Faster debugging of static analysis violations
