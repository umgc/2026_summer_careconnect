"""
Tool section renderers for the CareConnect Quality Gate HTML report.

Functions
---------
tool_findings_html(findings, reason, normalized) -> str
    Render the findings section for a tool result.
tool_section(result) -> str
    Render a full tool detail section.
"""

from quality.ci.gate.report.report_constants import CATEGORY_MAP
from quality.ci.gate.report.render_report.report_badges import (
    tool_status,
    tool_role,
    tool_reason_html,
    sev_pills,
)
from quality.ci.gate.report.render_report.report_rows import finding_row


def tool_findings_html(
    findings: list[dict],
    reason: str,
    normalized: dict,
) -> str:
    """Render the findings section for a tool result."""
    if findings:
        rows = "\n".join(finding_row(f) for f in findings)
        return f"""
        <table>
            <thead><tr>
                <th>Severity</th><th>File</th><th>Line</th>
                <th>Rule</th><th>Message</th>
            </tr></thead>
            <tbody>
                {rows}
                <tr class="no-results">
                    <td colspan="5" style="color:#7f8c8d;font-style:italic;">
                        No findings match the current filters.
                    </td>
                </tr>
            </tbody>
        </table>"""

    if reason == "disabled":
        return "<p><em>Tool is disabled.</em></p>"

    if normalized.get("runtime_error", False):
        error_message = (normalized.get("metadata") or {}).get("error", "Unknown error")
        return f"<p><em>Runtime error: {error_message}</em></p>"

    if not normalized.get("executed", False):
        return "<p><em>Tool did not execute.</em></p>"

    return "<p><em>No findings detected.</em></p>"


def tool_section(result: dict) -> str:
    """Render a full tool detail section."""
    tool = result.get("tool", "unknown")
    category = CATEGORY_MAP.get(tool, "Analysis")
    violation = result.get("policy_violation", False)
    blocking = result.get("blocking", False)
    reason = result.get("reason", "")
    normalized = result.get("normalized", {})
    findings = normalized.get("findings", [])
    severity_counts = normalized.get("severity_counts", {})

    status_html, header_color = tool_status(reason, violation)
    role_html = tool_role(blocking)
    reason_html = tool_reason_html(reason)
    findings_html = tool_findings_html(findings, reason, normalized)
    back_link = '<a href="#tool-results-summary" style="font-size:0.8em;color:#2980b9;text-decoration:none;">↑ Back to summary</a>'

    return f"""
    <div class="tool-section" id="tool-{tool}" data-tool="{tool}">
        <div class="tool-header" style="border-left:4px solid {header_color};">
            <div class="tool-title">
                <span class="tool-name">{tool}</span>
                <span class="tool-category">{category}</span>
                <span style="margin-left:auto;">{back_link}</span>
            </div>
            <div class="tool-meta">
                {status_html}
                <span style="margin-left:12px;">Role: {role_html}</span>
                {reason_html}
            </div>
            <div class="sev-counts">{sev_pills(severity_counts)}</div>
        </div>
        <div class="tool-findings">
            {findings_html}
            <div style="text-align:right;padding:8px 0 4px;">
                {back_link}
            </div>
        </div>
    </div>"""
