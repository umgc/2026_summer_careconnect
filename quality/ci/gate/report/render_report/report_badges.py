"""
Badge and pill renderers for the CareConnect Quality Gate HTML report.

Functions
---------
severity_badge(severity) -> str
    Render an HTML severity badge.
sev_pills(sev_counts) -> str
    Render severity count pills for a tool section.
tool_status(reason, violation) -> tuple[str, str]
    Return status HTML and header color for a tool result.
tool_role(blocking) -> str
    Return role HTML for a tool result.
tool_reason_html(reason) -> str
    Return optional reason HTML for a tool result.
"""

from quality.ci.gate.report.report_constants import SEVERITY_COLORS


def severity_badge(severity: str | None) -> str:
    """Render an HTML severity badge."""
    if not severity:
        return "<span>&mdash;</span>"

    color = SEVERITY_COLORS.get(severity.lower(), "#95a5a6")
    return (
        f'<span style="background:{color};color:#fff;padding:2px 8px;'
        f'border-radius:4px;font-size:0.85em;font-weight:bold;">'
        f"{severity.upper()}</span>"
    )


def sev_pills(sev_counts: dict) -> str:
    """Render severity count pills for a tool section."""
    pills = ""

    for level in ["critical", "high", "medium", "low", "info"]:
        count = sev_counts.get(level, 0)
        if count:
            color = SEVERITY_COLORS.get(level, "#95a5a6")
            pills += (
                f'<span style="background:{color};color:#fff;padding:2px 8px;'
                f'border-radius:4px;font-size:0.8em;margin-right:4px;">'
                f"{level.upper()}: {count}</span>"
            )

    return pills or '<span style="color:#7f8c8d;">No findings</span>'


def tool_status(reason: str, violation: bool) -> tuple[str, str]:
    """Return status HTML and header color for a tool result."""
    if reason == "disabled":
        return '<span style="color:#7f8c8d;">DISABLED</span>', "#7f8c8d"
    if violation:
        return '<span style="color:#c0392b;">FAILURE</span>', "#c0392b"
    return '<span style="color:#27ae60;">SUCCESS</span>', "#27ae60"


def tool_role(blocking: bool) -> str:
    """Return role HTML for a tool result."""
    return (
        '<span style="color:#c0392b;">Enforced</span>'
        if blocking
        else '<span style="color:#e67e22;">Advisory</span>'
    )


def tool_reason_html(reason: str) -> str:
    """Return optional reason HTML for a tool result."""
    if not reason or reason == "disabled":
        return ""

    return (
        f'<span style="margin-left:12px;color:#7f8c8d;font-size:0.85em;">'
        f"Reason: <code>{reason}</code></span>"
    )
