"""
CSS styles for the CareConnect Local Quality Gate HTML report.
"""

CSS = """
* { box-sizing: border-box; margin: 0; padding: 0; }
body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    background: #f5f6fa; color: #2c3e50; padding: 24px; font-size: 14px;
}
h1 { font-size: 1.6em; margin-bottom: 8px; }
h2 { font-size: 1.2em; margin: 24px 0 12px; padding-bottom: 6px;
     border-bottom: 2px solid #dde; }
h3 { font-size: 1em; margin-bottom: 8px; color: #555; }
.banner { padding: 12px 20px; border-radius: 6px; color: #fff;
          font-weight: bold; font-size: 1.05em; margin: 16px 0; }
.info-card { background: #fff; border-radius: 6px; padding: 16px 20px;
             margin-bottom: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); }
.info-table td { padding: 4px 12px 4px 0; vertical-align: top; }
.info-table td:first-child { color: #7f8c8d; white-space: nowrap; }
table { width: 100%; border-collapse: collapse; background: #fff;
        border-radius: 6px; overflow: hidden;
        box-shadow: 0 1px 3px rgba(0,0,0,0.08); margin-bottom: 16px; }
th { background: #2c3e50; color: #fff; padding: 10px 14px; text-align: left;
     font-size: 0.85em; text-transform: uppercase; letter-spacing: 0.05em; }
td { padding: 8px 14px; border-bottom: 1px solid #eee; vertical-align: top; }
tr:last-child td { border-bottom: none; }
tr:hover td { background: #f8f9fa; }
code { background: #f0f2f5; padding: 2px 6px; border-radius: 3px;
       font-size: 0.9em; font-family: "SFMono-Regular", Consolas, monospace; }
.tool-section { background: #fff; border-radius: 6px; margin-bottom: 20px;
                box-shadow: 0 1px 3px rgba(0,0,0,0.08); overflow: hidden; }
.tool-header { padding: 14px 20px; background: #fafbfc;
               border-bottom: 1px solid #eee; }
.tool-title { display: flex; align-items: center; gap: 12px; margin-bottom: 6px; }
.tool-name { font-weight: bold; font-size: 1.05em;
             font-family: "SFMono-Regular", Consolas, monospace; }
.tool-category { color: #7f8c8d; font-size: 0.85em; }
.tool-meta { display: flex; align-items: center;
             margin-bottom: 8px; font-size: 0.9em; }
.sev-counts { margin-top: 6px; }
.tool-findings { padding: 16px 20px; }
.section-header { background: #2c3e50; color: #fff; padding: 10px 20px;
                  border-radius: 6px; margin: 24px 0 12px;
                  font-weight: bold; font-size: 1.05em; }
a.tool-link { color: #2980b9; text-decoration: none;
              font-family: "SFMono-Regular", Consolas, monospace; }
a.tool-link:hover { text-decoration: underline; }
a.back-link { color: #7f8c8d; font-size: 0.85em; text-decoration: none;
              margin-left: auto; }
a.back-link:hover { text-decoration: underline; }
footer { margin-top: 32px; padding-top: 12px;
         border-top: 1px solid #dde; color: #7f8c8d; font-size: 0.85em; }
.hidden { display: none !important; }
.no-results { color: #7f8c8d; padding: 12px 0; font-style: italic; }

/* Filter bar */
.filter-bar {
    display: flex; align-items: flex-end; gap: 16px; flex-wrap: wrap;
    background: #fff; border-radius: 6px; padding: 14px 20px;
    margin-bottom: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.08);
}
.filter-bar label { display: block; font-size: 0.8em;
                    color: #7f8c8d; margin-bottom: 4px; }
.filter-bar select, .filter-bar input[type="text"] {
    padding: 6px 10px; border: 1px solid #dde; border-radius: 4px;
    font-size: 0.9em; background: #fafbfc;
}
.filter-bar input[type="text"] {
    width: 600px;
}
font-size: 0.9em; background: #fafbfc;
}
.search-wrap { display: flex; flex-direction: column; flex: 2; min-width: 350px; }
.search-wrap > div { display: flex; gap: 6px; }
.btn-clear, .btn-reset {
    padding: 6px 14px; border: none; border-radius: 4px;
    cursor: pointer; font-size: 0.85em;
}
.btn-clear { background: #ecf0f1; color: #2c3e50; }
.btn-reset { background: #2c3e50; color: #fff; align-self: flex-end; }
.btn-clear:hover { background: #dde; }
.btn-reset:hover { background: #34495e; }

/* Toggle switch */
.toggle-wrap { display: flex; justify-content: center; }
.toggle { position: relative; display: inline-block; width: 36px; height: 20px; }
.toggle input { opacity: 0; width: 0; height: 0; }
.slider { position: absolute; cursor: pointer; inset: 0;
          background: #ccc; border-radius: 20px; transition: 0.3s; }
.slider:before { position: absolute; content: "";
                 height: 14px; width: 14px; left: 3px; bottom: 3px;
                 background: #fff; border-radius: 50%; transition: 0.3s; }
input:checked + .slider { background: #27ae60; }
input:checked + .slider:before { transform: translateX(16px); }
"""
