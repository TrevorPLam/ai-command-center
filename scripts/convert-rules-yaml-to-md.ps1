# Convert 00-RULES.yaml to 00-RULES.md
# This script regenerates the human-readable rules document from the YAML source

param(
    [string]$YamlPath = "docs/plan/00-RULES.yaml",
    [string]$MdPath = "docs/plan/00-RULES.md"
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
$inRulesSection = $false

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

# Group rules by domain
$groupedRules = @{}
foreach ($rule in $rules) {
    $domain = $rule.domain
    if (-not $groupedRules.ContainsKey($domain)) {
        $groupedRules[$domain] = @()
    }
    $groupedRules[$domain] += $rule
}

# Generate Markdown
$mdLines = @()
$mdLines += "# Unified Rules Register"
$mdLines += ""
$mdLines += "This document provides a human-readable view of all project rules. For the authoritative source, see [00-RULES.yaml](00-RULES.yaml)."
$mdLines += ""
$mdLines += "All rules are categorized by domain with severity levels:"
$mdLines += "- **HARD**: Violations will block a PR or deployment"
$mdLines += "- **MEDIUM**: Best practices that should be followed"
$mdLines += ""
$mdLines += "---"
$mdLines += ""

# Domain order and display names
$domainOrder = @{
    "backend" = "Backend Rules (BE-)"
    "frontend" = "Frontend Rules (FE-)"
    "ai" = "AI Core Rules (AI-)"
    "security" = "Security Rules (SEC-)"
    "collaboration" = "Collaboration Rules (COLL-)"
}

# Generate tables for each domain
foreach ($domainKey in $domainOrder.Keys) {
    if ($groupedRules.ContainsKey($domainKey)) {
        $domainRules = $groupedRules[$domainKey]
        $domainName = $domainOrder[$domainKey]
        
        $mdLines += "## $domainName"
        $mdLines += ""
        $mdLines += "| ID | Severity | Description | Check |"
        $mdLines += "|----|----------|-------------|-------|"
        
        foreach ($rule in $domainRules | Sort-Object id) {
            $id = $rule.id
            $severity = $rule.severity
            $description = $rule.description
            $check = $rule.check
            
            # Escape pipe characters in description
            $description = $description -replace '\|', '\|'
            $check = $check -replace '\|', '\|'
            
            $mdLines += "| $id | $severity | $description | $check |"
        }
        
        $mdLines += ""
        $mdLines += "---"
        $mdLines += ""
    }
}

# Generate summary
$totalRules = $rules.Count
$hardRules = ($rules | Where-Object { $_.severity -eq "HARD" }).Count
$mediumRules = ($rules | Where-Object { $_.severity -eq "MEDIUM" }).Count

$mdLines += "## Summary"
$mdLines += ""
$mdLines += "- **Total Rules**: $totalRules"
$mdLines += "- **HARD Rules**: $hardRules"
$mdLines += "- **MEDIUM Rules**: $mediumRules"

foreach ($domainKey in $domainOrder.Keys) {
    if ($groupedRules.ContainsKey($domainKey)) {
        $count = $groupedRules[$domainKey].Count
        $displayName = ($domainOrder[$domainKey] -split ' ')[0]
        $mdLines += "- **$displayName Rules**: $count"
    }
}

# Write to file
$mdContent = $mdLines -join "`n"
$mdContent | Out-File -FilePath $MdPath -Encoding UTF8 -NoNewline

Write-Host "Successfully generated $MdPath from $YamlPath"
Write-Host "Total rules: $totalRules"
