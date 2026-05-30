"""
Filter bar and legend block HTML constants for the CareConnect Local Quality Gate report.
"""

FILTER_BAR = """
<div class="filter-bar">
    <div>
        <label for="sev-filter">Severity</label>
        <select id="sev-filter">
            <option value="all">All</option>
            <option value="critical">Critical only</option>
            <option value="high">High and above</option>
            <option value="medium">Medium and above</option>
            <option value="low">Low and above</option>
        </select>
    </div>
    <div class="search-wrap">
        <label for="search-input">Search</label>
        <div>
            <input type="text" id="search-input"
                   placeholder="file path, rule, or message..." />
            <button class="btn-clear" id="btn-clear">Clear</button>
        </div>
    </div>
    <button class="btn-reset" id="btn-reset">Reset</button>
</div>
"""

LEGEND_BLOCK = """
<div class="info-card">
    <h3>Legend</h3>
    <table class="info-table">
        <tr><td>PASSED</td>
            <td>Tool ran and found no violations</td></tr>
        <tr><td>FAILED</td>
            <td>Tool found one or more violations</td></tr>
        <tr><td>SKIPPED</td>
            <td>Tool did not run (project type not detected)</td></tr>
        <tr><td>Advisory</td>
            <td>Violations from this tool are advisory but do not block the merge</td></tr>
    </table>
</div>"""
