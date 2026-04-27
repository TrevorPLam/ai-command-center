# Generate 100-FRONTEND-RULES.md from 00-RULES.yaml
# This script regenerates the frontend-specific rules document from the YAML source

param(
    [string]$YamlPath = "docs/plan/00-RULES.yaml",
    [string]$MdPath = "docs/plan/100-FRONTEND-RULES.md"
)

# Check if YAML file exists
if (-not (Test-Path $YamlPath)) {
    Write-Error "YAML file not found: $YamlPath"
    exit 1
}

# Read and parse YAML
$yamlContent = Get-Content $YamlPath -Raw

# Parse YAML manually (PowerShell doesn't have built-in YAML parsing)
$rules = @()
$currentDomain = ""

foreach ($line in $yamlContent -split "`n") {
    if ($line -match "^  # (\w+) Rules") {
        $currentDomain = $matches[1].ToLower()
        continue
    }
    
    if ($line -match "^\s*-\s*id:\s*(\S+)") {
        $rule = @{
            id = $matches[1]
            domain = ""
            severity = ""
            description = ""
            check = ""
        }
        $rules += $rule
    }
    
    if ($line -match "^\s+domain:\s*(\S+)") {
        if ($rules.Count -gt 0) {
            $rules[-1].domain = $matches[1]
        }
    }
    
    if ($line -match "^\s+severity:\s*(\S+)") {
        if ($rules.Count -gt 0) {
            $rules[-1].severity = $matches[1].ToUpper()
        }
    }
    
    if ($line -match "^\s+description:\s*(.+)") {
        if ($rules.Count -gt 0) {
            $rules[-1].description = $matches[1].Trim()
        }
    }
    
    if ($line -match "^\s+check:\s*(.+)") {
        if ($rules.Count -gt 0) {
            $rules[-1].check = $matches[1].Trim()
        }
    }
}

# Filter frontend rules
$frontendRules = $rules | Where-Object { $_.domain -eq "frontend" }

# Define topic sections with rule ID ranges
$topics = @{
    "Z-index" = @("FE-09")
    "Zustand state" = @("FE-10", "FE-11", "FE-12")
    "React compiler & memoization" = @("FE-13", "FE-14", "FE-15")
    "UI patterns" = @("FE-16", "FE-17", "FE-18", "FE-19", "FE-20", "FE-21", "FE-22", "FE-23", "FE-24", "FE-25")
    "Drag & drop" = @("FE-26", "FE-27", "FE-28")
    "Editor / Monaco" = @("FE-29", "FE-30")
    "Storage" = @("FE-31", "FE-32")
    "URL state" = @("FE-33")
    "Design tokens" = @("FE-34")
    "Accessibility (all UI)" = @("FE-35", "FE-36", "FE-37")
}

# Generate Markdown
$mdLines = @()
$mdLines += "# Frontend rules"
$mdLines += ""
$mdLines += "> **Auto-generated**: This file is generated from [00-RULES.yaml](00-RULES.yaml). Do not edit directly. Source: `00-RULES.yaml` (filter by domain `frontend`)."
$mdLines += ""
$mdLines += "These rules apply to all frontend code. Violating a **HARD** rule will block a PR."
$mdLines += ""
$mdLines += "---"
$mdLines += ""

# Generate each topic section
foreach ($topicName in $topics.Keys) {
    $ruleIds = $topics[$topicName]
    
    $mdLines += "## $topicName"
    $mdLines += ""
    
    foreach ($ruleId in $ruleIds) {
        $rule = $frontendRules | Where-Object { $_.id -eq $ruleId }
        if ($rule) {
            $mdLines += "- #$($rule.id): $($rule.description)"
        }
    }
    
    # Add React compiler assessment after that section
    if ($topicName -eq "React compiler & memoization") {
        $mdLines += ""
        $mdLines += "### React compiler production readiness assessment (April 2026)"
        $mdLines += ""
        $mdLines += "- **Status**: React Compiler v1.0 released October 7, 2025 - STABLE release"
        $mdLines += "- **Production Validation**: Battle-tested on major apps at Meta (e.g., Meta Quest Store)"
        $mdLines += "- **Performance Results**: Up to 12% improvement in initial loads and cross-page navigations; some interactions >2.5× faster; memory usage stays neutral"
        $mdLines += "- **Compatibility**: React 17 and up; safe by design (skips optimization if cannot safely optimize rather than breaking code)"
        $mdLines += "- **Known Issues**: Some third-party library hooks return new objects on every render, breaking memoization chains (e.g., TanStack Query's useMutation(), Material UI's useTheme(), React Router's useLocation())"
        $mdLines += "- **Recommendation**: Only compile own source code with React Compiler; do NOT compile 3rd-party code. Library authors have full control over whether to use React Compiler or manually optimize."
    }
    
    $mdLines += ""
    $mdLines += "---"
    $mdLines += ""
}

# Write to file with UTF-8 encoding (no BOM)
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$mdContent = $mdLines -join "`n"
[System.IO.File]::WriteAllText($MdPath, $mdContent, $utf8NoBom)

# Add trailing newline
Add-Content -Path $MdPath -Value "" -Encoding UTF8

Write-Host "Successfully generated $MdPath from $YamlPath"
Write-Host "Total frontend rules: $($frontendRules.Count)"
