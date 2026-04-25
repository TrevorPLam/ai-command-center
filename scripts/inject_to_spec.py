#!/usr/bin/env python3
"""
inject_to_spec.py
Parses the expanded Plan3 master document (00-Plan3.md) and populates the
SpecTree directory (spec/). Each concept gets its own file with YAML frontmatter
and a Markdown body. Designed to be run from the project root.
"""

import re
import os
import yaml
from pathlib import Path
from datetime import datetime, timezone
from typing import Dict, List, Tuple, Optional, Any

# ---------------------------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------------------------
BASE_DIR = Path(__file__).parent.parent.parent.resolve()
PLAN3_FILE = BASE_DIR / "00-Plan3.md"
SPEC_DIR = BASE_DIR / "spec"

MODULE_LETTER_TO_DIR = {
    "F": "foundation",
    "D": "dashboard",
    "C": "chat",
    "W": "workflows",
    "P": "projects",
    "A": "calendar",
    "E": "email",
    "K": "contacts",
    "CF": "conference",
    "T": "translation",
    "N": "news",
    "DC": "documents",
    "R": "research",
    "M": "media",
    "B": "budget",
    "S": "settings",
    "PL": "platform",
}


# ---------------------------------------------------------------------------
# HELPER FUNCTIONS
# ---------------------------------------------------------------------------
def read_file(filepath: Path) -> str:
    with open(filepath, "r", encoding="utf-8") as f:
        return f.read()


def ensure_dir(path: Path):
    path.mkdir(parents=True, exist_ok=True)


def write_spec_file(filepath: Path, frontmatter: Dict[str, Any], body: str):
    """Write a spec file with YAML frontmatter and Markdown body."""
    ensure_dir(filepath.parent)
    frontmatter_str = yaml.dump(frontmatter, default_flow_style=False, sort_keys=False, allow_unicode=True).strip()
    content = f"---\n{frontmatter_str}\n---\n\n{body}\n"
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)


def extract_table(text: str) -> List[Dict[str, str]]:
    """
    Extract a pipe-delimited table. Returns list of dicts.
    Handles optional checkboxes at start of rows.
    """
    rows = []
    for line in text.strip().splitlines():
        line = line.strip()
        if not line or not line.startswith("|"):
            continue
        parts = [p.strip() for p in line.split("|")[1:-1]]  # drop outer empty
        if not parts:
            continue
        # Skip header/separator rows (e.g., "|---|---|" or "key columns bold")
        if all(re.match(r"^[-:]+$", p) for p in parts):
            continue
        rows.append(parts)
    return rows


def extract_section(content: str, marker: str) -> str:
    """Extract content of a section until the next top-level heading (## or #)."""
    pattern = rf"^\s*###? {re.escape(marker)}\s*\n(.*?)(?=\n###? |\Z)"
    match = re.search(pattern, content, re.MULTILINE | re.DOTALL)
    return match.group(1).strip() if match else ""


def extract_module_tables(content: str) -> Dict[str, List[Dict]]:
    """Extract module registry tables grouped by module letter."""
    modules = {}
    # Match each module section heading and its table
    pattern = r"###\s+(\w+)\s+\((\w+)\).*?\n\n\| Component \|.*?\n(.*?)(?=\n###\s|\Z)"
    for match in re.finditer(pattern, content, re.DOTALL):
        module_key = match.group(2)
        table_text = match.group(3)
        rows = extract_table(table_text)
        modules[module_key] = rows
    return modules


def extract_frontmatter_table(text: str, headers: List[str]) -> List[Dict]:
    """Convert a table into a list of dicts with given headers."""
    rows = extract_table(text)
    result = []
    for row in rows:
        entry = {}
        for i, header in enumerate(headers):
            entry[header] = row[i] if i < len(row) else ""
        result.append(entry)
    return result


# ---------------------------------------------------------------------------
# MAIN PARSING LOGIC
# ---------------------------------------------------------------------------
def main():
    print("Parsing 00-Plan3.md...")
    plan3 = read_file(PLAN3_FILE)

    # 1. LEXICON & ALIASES
    print("  Extracting lexicon...")
    abbr_table = extract_table(extract_section(plan3, "Common Abbreviations"))
    anim_table = extract_table(extract_section(plan3, "Animation Tags"))
    pattern_table = extract_table(extract_section(plan3, "Pattern Tags"))
    pkg_table = extract_table(extract_section(plan3, "Package Aliases"))
    dir_table = extract_table(extract_section(plan3, "Directory Aliases"))

    # 2. UI/UX Design Tokens
    print("  Extracting design tokens...")
    token_table = extract_table(extract_section(plan3, "UI/UX DESIGN TOKENS & BEHAVIOUR RULES"))

    # 3. HARD GLOBAL RULES
    print("  Extracting hard rules...")
    security_rules = extract_section(plan3, "Security \\(S‑series\\)")
    browser_rules = extract_section(plan3, "Browser / UI \\(B‑series\\)")
    perf_rules = extract_section(plan3, "Performance \\(P‑series\\)")
    control_rules = extract_section(plan3, "Control Rules \\(Legacy g‑series; for backwards compatibility\\)")

    # 4. VERSIONS
    print("  Extracting versions...")
    versions_table = extract_table(extract_section(plan3, "VERSIONS"))

    # 5. QUERY CLIENT
    print("  Extracting query client config...")
    query_table = extract_table(extract_section(plan3, "QUERY CLIENT"))

    # 6. STATE ARCHITECTURE
    print("  Extracting state slices...")
    state_table = extract_table(extract_section(plan3, "STATE ARCHITECTURE \\(ZUSTAND SLICES\\)"))

    # 7. ROUTES
    print("  Extracting routes...")
    routes_table = extract_table(extract_section(plan3, "ROUTES"))

    # 8. DATABASE TABLES
    print("  Extracting database tables...")
    db_tables = extract_table(extract_section(plan3, "Tables"))

    # 9. BACKEND ENDPOINTS
    print("  Extracting backend endpoints...")
    endpoints_table = extract_table(extract_section(plan3, "BACKEND ENDPOINTS"))

    # 10. MODULE REGISTRY
    print("  Extracting module components...")
    module_components = extract_module_tables(plan3)

    # 11. EXTERNAL INTEGRATIONS
    print("  Extracting integrations...")
    # We'll handle individually: Nylas, LiveKit, AI Providers, Y‑Sweet, Storage, Search, Security
    # For simplicity, we can extract their section contents as prose.
    nylas = extract_section(plan3, "Nylas \\(Email/Calendar\\)")
    livekit = extract_section(plan3, "LiveKit \\(Video Conferencing\\)")
    ai_providers = extract_section(plan3, "AI Providers \\(via LiteLLM Proxy\\)")
    y_sweet = extract_section(plan3, "Y‑Sweet \\(Collaborative Documents\\)")
    storage = extract_section(plan3, "Storage Strategy")
    search_strategy = extract_section(plan3, "Search Strategy")
    dompurify = extract_section(plan3, "DOMPurify Configuration")
    observability = extract_section(plan3, "Observability")
    testing = extract_section(plan3, "Testing Strategy")
    perf_budget = extract_section(plan3, "Performance Budgets")

    # 12. SYSTEM FLOWS
    print("  Extracting system flows...")
    login_flow = extract_section(plan3, "Login Flow")
    chat_flow = extract_section(plan3, "Chat Message Flow")
    email_flow = extract_section(plan3, "Email Send Flow")

    # 13. ADR
    print("  Extracting ADRs...")
    adr_table = extract_table(extract_section(plan3, "ADOPTED ARCHITECTURE DECISIONS \\(ADR\\)"))

    # 14. RUNBOOKS
    print("  Extracting runbooks...")
    ai_outage = extract_section(plan3, "Scenario: AI Provider Failure")
    supabase_outage = extract_section(plan3, "Scenario: Supabase Outage")

    # 15. BACKEND ARCHITECTURE DETAILS
    print("  Extracting backend architecture...")
    backend_details = extract_section(plan3, "Backend Architecture Details")
    error_codes = extract_section(plan3, "Error Codes")

    # =======================================================================
    # WRITE SPEC FILES
    # =======================================================================
    print("Writing spec files...")

    # 1. 00-INDEX.md
    print("  Writing 00-INDEX.md...")
    index_body = "# SpecTree Index\n\n"
    index_body += "## Lexicon\n\n"
    index_body += "| Abbreviation | Full Term |\n|--------------|-----------|\n"
    for row in abbr_table:
        index_body += f"| {row[0]} | {row[1]} |\n"

    index_body += "\n## Animation Tags\n\n| Tag | Meaning |\n|-----|--------|\n"
    for row in anim_table:
        index_body += f"| {row[0]} | {row[1]} |\n"

    index_body += "\n## Pattern Tags\n\n| Tag | Description |\n|-----|-------------|\n"
    for row in pattern_table:
        index_body += f"| {row[0]} | {row[1]} |\n"

    index_body += "\n## Package Aliases\n\n| Alias | Full Package |\n|-------|-------------|\n"
    for row in pkg_table:
        index_body += f"| {row[0]} | {row[1]} |\n"

    index_body += "\n## Directory Aliases\n\n| Alias | Path |\n|-------|-----|\n"
    for row in dir_table:
        index_body += f"| {row[0]} | {row[1]} |\n"

    write_spec_file(
        SPEC_DIR / "00-INDEX.md",
        {
            "id": "00-index",
            "title": "SpecTree Index",
            "type": "index",
            "last_updated": datetime.now(timezone.utc).isoformat(),
        },
        index_body,
    )

    # 2. CONTRACTS: patterns
    print("  Writing patterns...")
    for row in pattern_table:
        tag = row[0]
        desc = row[1]
        write_spec_file(
            SPEC_DIR / "contracts" / "patterns" / f"{tag}.md",
            {
                "id": f"pattern.{tag}",
                "title": f"{tag} Pattern",
                "type": "pattern",
                "compressed_description": desc,
                "last_updated": datetime.now(timezone.utc).isoformat(),
            },
            f"# {tag}\n\n{desc}",
        )

    # 3. CONTRACTS: rules
    print("  Writing rules...")
    def parse_rule_list(section_text, category):
        rules = []
        for line in section_text.splitlines():
            match = re.match(r"- \[(.)\] \*\*(\w+)\*\* : (.*)", line)
            if match:
                rules.append({
                    "id": match.group(2),
                    "enforced": match.group(1) == "x",
                    "text": match.group(3).strip(),
                    "category": category,
                })
        return rules

    all_rules = []
    all_rules.extend(parse_rule_list(security_rules, "security"))
    all_rules.extend(parse_rule_list(browser_rules, "browser"))
    all_rules.extend(parse_rule_list(perf_rules, "performance"))

    # Control rules (table)
    control_rows = extract_table(control_rules) if control_rules else []
    for row in control_rows:
        all_rules.append({
            "id": row[0],
            "text": row[1],
            "category": "control",
        })

    for rule in all_rules:
        rid = rule["id"]
        filename = f"{rid}.md"
        body = f"# {rid}\n\n{rule['text']}"
        write_spec_file(
            SPEC_DIR / "contracts" / "rules" / filename,
            {
                "id": f"rule.{rid}",
                "title": rid,
                "type": "rule",
                "category": rule["category"],
                "compressed_description": rule["text"],
                "last_updated": datetime.now(timezone.utc).isoformat(),
            },
            body,
        )

    # 4. STATE SLICES
    print("  Writing state slices...")
    for row in state_table:
        if len(row) < 5:
            continue
        name = row[0]
        fields = row[1]
        stype = row[2]
        persist = row[3]
        notes = row[4] if len(row) > 4 else ""
        filename = name.replace("Slice", "-slice").replace("Store", "-store").lower() + ".md"
        body = f"# {name}\n\n## Fields\n{fields}\n\n## Persist Policy\n{persist}\n\n{notes}"
        write_spec_file(
            SPEC_DIR / "foundation" / "state" / filename,
            {
                "id": f"state.{filename[:-3]}",
                "title": name,
                "type": "state-slice",
                "state_slice_name": name,
                "fields": fields,
                "persist_policy": persist,
                "notes": notes,
                "last_updated": datetime.now(timezone.utc).isoformat(),
            },
            body,
        )

    # 5. ROUTES
    print("  Writing routes...")
    route_body = "# Route Table\n\n| Path | Page Component | Lazy | Notes |\n|------|---------------|------|-------|\n"
    for row in routes_table:
        if len(row) < 3:
            continue
        path, page, lazy = row[:3]
        notes = row[3] if len(row) > 3 else ""
        route_body += f"| {path} | {page} | {lazy} | {notes} |\n"
    write_spec_file(
        SPEC_DIR / "foundation" / "router" / "routes.md",
        {
            "id": "routes",
            "title": "Route Table",
            "type": "route-table",
            "last_updated": datetime.now(timezone.utc).isoformat(),
        },
        route_body,
    )

    # 6. DATA SCHEMAS
    print("  Writing data schemas...")
    for row in db_tables:
        if len(row) < 4:
            continue
        table_name = row[0].lower()
        keys = row[1]
        shared = row[2]
        notes = row[3]
        body = f"# {table_name}\n\n- **Key Columns:** {keys}\n- **Shared:** {shared}\n- **Notes:** {notes}"
        write_spec_file(
            SPEC_DIR / "data" / "schema" / f"{table_name}.md",
            {
                "id": f"data.{table_name}",
                "title": f"{table_name} table",
                "type": "data-schema",
                "table": table_name,
                "shared": shared,
                "key_columns": keys,
                "notes": notes,
                "last_updated": datetime.now(timezone.utc).isoformat(),
            },
            body,
        )

    # 7. MODULES
    print("  Writing modules...")
    for mod_letter, components in module_components.items():
        for comp in components:
            if len(comp) < 7:
                continue
            name = comp[0].strip()
            anim = comp[1].strip()
            patterns = comp[2].strip()
            rules = comp[3].strip()
            dependencies = comp[4].strip()
            notes = comp[5].strip()
            tasks = comp[6].strip() if len(comp) > 6 else ""

            kebab_name = re.sub(r"(?<!^)(?=[A-Z])", "-", name).lower()
            module_dir = MODULE_LETTER_TO_DIR.get(mod_letter, "platform")
            filepath = SPEC_DIR / module_dir / f"{kebab_name}.md"

            body = f"# {name}\n\n## Animation\n{anim}\n\n## Patterns\n{patterns}\n\n## Rules\n{rules}\n\n## Dependencies\n{dependencies}\n\n## Notes\n{notes}\n\n## Tasks\n{tasks}"
            write_spec_file(
                filepath,
                {
                    "id": f"module.{mod_letter}.{kebab_name}",
                    "title": name,
                    "type": "module",
                    "module": mod_letter,
                    "component": name,
                    "anim_tier": anim,
                    "contracts_used": [p.strip() for p in patterns.split("+") if p.strip()],
                    "global_rules": [r.strip() for r in rules.split("+") if r.strip()],
                    "dependencies": dependencies,
                    "notes": notes,
                    "tasks": tasks,
                    "last_updated": datetime.now(timezone.utc).isoformat(),
                },
                body,
            )
            print(f"    {module_dir}/{kebab_name}.md")

    # 8. INTEGRATIONS
    print("  Writing integrations...")
    for name, content in [
        ("Nylas", nylas),
        ("LiveKit", livekit),
        ("AI Providers", ai_providers),
        ("Y-Sweet", y_sweet),
        ("Storage Strategy", storage),
        ("Search Strategy", search_strategy),
    ]:
        if content:
            filename = name.lower().replace(" ", "-").replace("(", "").replace(")", "") + ".md"
            write_spec_file(
                SPEC_DIR / "integrations" / filename,
                {
                    "id": f"integration.{filename[:-3]}",
                    "title": name,
                    "type": "integration",
                    "compressed": content,
                    "last_updated": datetime.now(timezone.utc).isoformat(),
                },
                f"# {name}\n\n{content}",
            )

    # 9. SECURITY & PRIVACY
    print("  Writing security configs...")
    # DOMPurify
    write_spec_file(
        SPEC_DIR / "security" / "dompurify.md",
        {
            "id": "security.dompurify",
            "title": "DOMPurify Configuration",
            "type": "security",
            "last_updated": datetime.now(timezone.utc).isoformat(),
        },
        dompurify,
    )
    # Observability
    write_spec_file(
        SPEC_DIR / "security" / "observability.md",
        {
            "id": "security.observability",
            "title": "Observability",
            "type": "security",
            "last_updated": datetime.now(timezone.utc).isoformat(),
        },
        observability,
    )
    # Testing
    write_spec_file(
        SPEC_DIR / "testing" / "strategy.md",
        {
            "id": "testing.strategy",
            "title": "Testing Strategy",
            "type": "test-spec",
            "last_updated": datetime.now(timezone.utc).isoformat(),
        },
        testing,
    )
    # Performance
    write_spec_file(
        SPEC_DIR / "platform" / "performance-budgets.md",
        {
            "id": "platform.performance-budgets",
            "title": "Performance Budgets",
            "type": "architecture",
            "last_updated": datetime.now(timezone.utc).isoformat(),
        },
        perf_budget,
    )

    # 10. SYSTEM FLOWS
    print("  Writing system flows...")
    write_spec_file(
        SPEC_DIR / "crosscutting" / "flows.md",
        {
            "id": "crosscutting.flows",
            "title": "System Flows",
            "type": "architecture",
            "last_updated": datetime.now(timezone.utc).isoformat(),
        },
        f"## Login Flow\n{login_flow}\n\n## Chat Message Flow\n{chat_flow}\n\n## Email Send Flow\n{email_flow}",
    )

    # 11. ADRs
    print("  Writing ADRs...")
    adr_body = "# ADRs\n\n| ID | Decision |\n|----|----------|\n"
    for row in adr_table:
        if len(row) >= 2:
            adr_body += f"| {row[0]} | {row[1]} |\n"
    write_spec_file(
        SPEC_DIR / "docs" / "adrs.md",
        {
            "id": "docs.adrs",
            "title": "Architecture Decision Records",
            "type": "documentation",
            "last_updated": datetime.now(timezone.utc).isoformat(),
        },
        adr_body,
    )

    # 12. RUNBOOKS
    print("  Writing runbooks...")
    write_spec_file(
        SPEC_DIR / "ops" / "runbooks" / "ai-outage.md",
        {
            "id": "runbook.ai-outage",
            "title": "AI Provider Failure Runbook",
            "type": "runbook",
            "last_updated": datetime.now(timezone.utc).isoformat(),
        },
        ai_outage,
    )
    write_spec_file(
        SPEC_DIR / "ops" / "runbooks" / "supabase-outage.md",
        {
            "id": "runbook.supabase-outage",
            "title": "Supabase Outage Runbook",
            "type": "runbook",
            "last_updated": datetime.now(timezone.utc).isoformat(),
        },
        supabase_outage,
    )

    # 13. BACKEND ARCHITECTURE
    print("  Writing backend architecture...")
    write_spec_file(
        SPEC_DIR / "crosscutting" / "architecture" / "backend-endpoints.md",
        {
            "id": "arch.backend-endpoints",
            "title": "Backend Endpoints",
            "type": "architecture",
            "last_updated": datetime.now(timezone.utc).isoformat(),
        },
        f"# Backend Endpoints\n\n## Endpoints\n\n{endpoints_table}\n\n## Architecture Details\n{backend_details}\n\n## Error Codes\n{error_codes}",
    )

    print("\n✅ SpecTree population complete.")


if __name__ == "__main__":
    main()