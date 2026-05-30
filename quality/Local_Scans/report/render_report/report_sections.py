"""
Tool section and summary table builders for the CareConnect Local Quality Gate report.
"""

from .report_constants import CATEGORY_MAP, TOOL_FLUTTER, TOOL_CHECKSTYLE, TOOL_PMD, TOOL_SPOTBUGS
from .report_constants import TOOL_ID_FLUTTER, TOOL_ID_CHECKSTYLE, TOOL_ID_PMD, TOOL_ID_SPOTBUGS
from .report_badges import status_html, border_color, sev_pills
from .report_rows import finding_row, summary_row


def _finding_rows(findings: list) -> str:
    """Render all finding rows for a tool section."""
    if not findings:
        return '<tr><td colspan="5" style="color:#7f8c8d;">No findings</td></tr>'
    return "".join(finding_row(f) for f in findings)


def tool_section(
    tool_id: str,
    tool_name: str,
    status: str,
    findings: list,
    severity_counts: dict,
) -> str:
    """Build one complete tool section."""
    category = CATEGORY_MAP.get(tool_name, "Analysis")
    return f"""
<div class="tool-section" id="tool-{tool_id}" data-tool="{tool_id}"
     style="border-left:4px solid {border_color(status)};">
    <div class="tool-header">
        <div class="tool-title">
            <span class="tool-name">{tool_name}</span>
            <span class="tool-category">{category}</span>
            <a class="back-link" href="#tool-results-summary">↑ Back to summary</a>
        </div>
        <div class="tool-meta">
            {status_html(status)}
            <span style="margin-left:12px;">
                Role: <span style="color:#c0392b;">Enforced</span>
            </span>
        </div>
        <div class="sev-counts">{sev_pills(severity_counts)}</div>
    </div>
    <div class="tool-findings">
        <div class="no-results" style="display:none;">
            No findings match the current filters.
        </div>
        <table>
            <thead>
                <tr>
                    <th>Severity</th>
                    <th>File</th>
                    <th>Line</th>
                    <th>Rule</th>
                    <th>Message</th>
                </tr>
            </thead>
            <tbody>
                {_finding_rows(findings)}
            </tbody>
        </table>
        <a class="back-link" href="#tool-results-summary"
           style="display:inline-block;margin-top:8px;">↑ Back to summary</a>
    </div>
</div>"""


def build_summary_table(context: dict) -> str:
    """Render the full Tool Results Summary table with toggles."""
    rows = (
        summary_row(TOOL_ID_FLUTTER, TOOL_FLUTTER,
                    context["fl_status"], context["fl_findings"])
        + summary_row(TOOL_ID_CHECKSTYLE, TOOL_CHECKSTYLE,
                      context["cs_status"], context["cs_findings"])
        + summary_row(TOOL_ID_PMD, TOOL_PMD,
                      context["pmd_status"], context["pmd_findings"])
        + summary_row(TOOL_ID_SPOTBUGS, TOOL_SPOTBUGS,
                      context["sb_status"], context["sb_findings"])
    )
    return f"""
<table>
    <thead>
        <tr>
            <th>Show</th>
            <th>Tool</th>
            <th>Category</th>
            <th>Status</th>
            <th>Role</th>
            <th>Findings</th>
        </tr>
    </thead>
    <tbody>
        {rows}
    </tbody>
</table>"""


def build_sections(context: dict) -> str:
    """Render all four tool sections."""
    sections = [
        tool_section(TOOL_ID_FLUTTER, TOOL_FLUTTER,
                     context["fl_status"], context["fl_findings"], context["fl_sev"]),
        tool_section(TOOL_ID_CHECKSTYLE, TOOL_CHECKSTYLE,
                     context["cs_status"], context["cs_findings"], context["cs_sev"]),
        tool_section(TOOL_ID_PMD, TOOL_PMD,
                     context["pmd_status"], context["pmd_findings"], context["pmd_sev"]),
        tool_section(TOOL_ID_SPOTBUGS, TOOL_SPOTBUGS,
                     context["sb_status"], context["sb_findings"], context["sb_sev"]),
    ]
    return "\n".join(sections)
