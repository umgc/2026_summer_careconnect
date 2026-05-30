"""
Metadata block renderers for the CareConnect Quality Gate HTML report.

Functions
---------
pr_block(env) -> str
    Render the pull request metadata block when applicable.
build_banner(overall_block) -> tuple[str, str]
    Build the banner color and text shown at the top of the report.
build_run_metadata(env) -> tuple[str, str, str]
    Build run-specific metadata used in the report header.
build_summary_rows(all_results) -> str
    Render the summary table rows for all evaluated tools.
build_tool_sections(blocking_results, non_blocking_results) -> tuple[str, str]
    Render the enforced and advisory tool sections.
"""

from quality.ci.gate.report.render_report.report_rows import summary_row
from quality.ci.gate.report.render_report.report_sections import tool_section


def pr_block(env: dict) -> str:
    """Render the pull request metadata block when applicable."""
    if env.get("event_name") != "pull_request" or not env.get("pr_number"):
        return ""

    return f"""
    <div class="info-card">
        <h3>Pull Request</h3>
        <table class="info-table">
            <tr><td><strong>PR Number</strong></td><td>#{env['pr_number']}</td></tr>
            <tr><td><strong>PR Author</strong></td><td>@{env['actor']}</td></tr>
            <tr><td><strong>Source Branch</strong></td>
                <td><code>{env['head_ref']}</code></td></tr>
            <tr><td><strong>Target Branch</strong></td>
                <td><code>{env['base_ref']}</code></td></tr>
        </table>
    </div>"""


def build_banner(overall_block: bool) -> tuple[str, str]:
    """
    Build the banner color and text shown at the top of the report.

    Parameters
    ----------
    overall_block : bool
        True when one or more enforced tools failed policy.

    Returns
    -------
    tuple[str, str]
        Banner color and banner message.
    """
    banner_color = "#c0392b" if overall_block else "#27ae60"
    banner_text = (
        "BLOCKED — One or more required checks failed. "
        "Fix the issues below before merging."
        if overall_block
        else "APPROVED — All required checks passed."
    )
    return banner_color, banner_text


def build_run_metadata(env: dict) -> tuple[str, str, str]:
    """
    Build run-specific metadata used in the report header.

    Parameters
    ----------
    env : dict
        Environment metadata collected by report.py.

    Returns
    -------
    tuple[str, str, str]
        Short SHA, run URL, and commit URL.
    """
    sha_short = env["sha"][:7] if env.get("sha") else "unknown"
    run_url = f"{env['server_url']}/{env['repository']}/actions/runs/{env['run_id']}"
    commit_url = f"{env['server_url']}/{env['repository']}/commit/{env['sha']}"
    return sha_short, run_url, commit_url


def build_summary_rows(all_results: list[dict]) -> str:
    """
    Render the summary table rows for all evaluated tools.

    Parameters
    ----------
    all_results : list[dict]
        Combined blocking and non-blocking evaluated results.

    Returns
    -------
    str
        HTML table rows for the summary table.
    """
    return "".join(summary_row(result) for result in all_results)


def build_tool_sections(
    blocking_results: list[dict],
    non_blocking_results: list[dict],
) -> tuple[str, str]:
    """
    Render the enforced and advisory tool sections.

    Parameters
    ----------
    blocking_results : list[dict]
        Evaluated results for enforced tools.
    non_blocking_results : list[dict]
        Evaluated results for advisory tools.

    Returns
    -------
    tuple[str, str]
        HTML for enforced-tool sections and advisory-tool sections.
    """
    blocking_sections = (
        "\n".join(tool_section(result) for result in blocking_results)
        or "<p><em>No enforced tools configured.</em></p>"
    )

    non_blocking_sections = (
        "\n".join(tool_section(result) for result in non_blocking_results)
        or "<p><em>No advisory tools configured.</em></p>"
    )

    return blocking_sections, non_blocking_sections
