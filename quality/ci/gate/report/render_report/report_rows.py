"""
Row renderers for the CareConnect Quality Gate HTML report.

Functions
---------
finding_row(finding) -> str
    Render a single finding row for the HTML findings table.
summary_row(result) -> str
    Render a summary table row for a tool including visibility toggle.
"""

from quality.ci.gate.report.report_constants import CATEGORY_MAP
from quality.ci.gate.report.render_report.report_badges import (
    tool_status,
    tool_role,
    severity_badge,
)


def finding_row(finding: dict) -> str:
    """Render a single finding row for the HTML findings table."""
    severity = finding.get("severity", "")
    message = str(finding.get("message", "—")).replace("<", "&lt;").replace(">", "&gt;")
    file_path = finding.get("file", "—")
    line = finding.get("line", "—")
    rule = finding.get("rule", "—")
    rule_url = finding.get("rule_url", "")

    rule_cell = f'<a href="{rule_url}" target="_blank">{rule}</a>' if rule_url else rule

    # data-text is used by JS search — combine searchable fields
    search_text = f"{file_path} {rule} {message}".lower()

    return (
        f'<tr class="finding-row" '
        f'data-severity="{severity.lower()}" '
        f'data-text="{search_text}">'
        f"<td>{severity_badge(severity)}</td>"
        f"<td><code>{file_path}</code></td>"
        f"<td>{line}</td>"
        f"<td>{rule_cell}</td>"
        f"<td>{message}</td>"
        f"</tr>"
    )


def summary_row(result: dict) -> str:
    """Render a summary table row for a tool including visibility toggle."""
    tool = result.get("tool", "unknown")
    category = CATEGORY_MAP.get(tool, "Analysis")
    violation = result.get("policy_violation", False)
    blocking = result.get("blocking", False)
    reason = result.get("reason", "")
    normalized = result.get("normalized", {})
    finding_count = normalized.get("violation_count", 0)

    status_cell, _ = tool_status(reason, violation)
    role_cell = tool_role(blocking)
    findings_cell = str(finding_count) if finding_count else "&mdash;"

    toggle = f"""
    <div class="toggle-wrap">
        <label class="toggle">
            <input type="checkbox" class="tool-toggle"
                   data-tool="{tool}" checked>
            <span class="slider"></span>
        </label>
    </div>"""

    return (
        "<tr>"
        f"<td>{toggle}</td>"
        f'<td><a class="tool-link" href="#tool-{tool}"><code>{tool}</code></a></td>'
        f"<td>{category}</td>"
        f"<td>{status_cell}</td>"
        f"<td>{role_cell}</td>"
        f"<td>{findings_cell}</td>"
        "</tr>\n"
    )
