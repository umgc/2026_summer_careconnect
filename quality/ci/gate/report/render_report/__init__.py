"""
render_report package for the CareConnect Quality Gate HTML report.

Exports
-------
build_html_report
    Build the full HTML quality gate report document.
"""

from quality.ci.gate.report.render_report.report_builder import build_html_report

__all__ = ["build_html_report"]
