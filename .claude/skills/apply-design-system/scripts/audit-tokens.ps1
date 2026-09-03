# audit-tokens.ps1 — flag design-token drift in an HTML/CSS file.
# Usage: powershell -ExecutionPolicy Bypass -File audit-tokens.ps1 path\to\file.html
#
# Reports, for CSS only (inside <style>, outside :root / dark-mode token blocks):
#   1. raw color literals (#hex / rgb() / rgba()) used in a rule instead of var(--token)
#   2. off-scale px in spacing properties (padding / margin / gap / inset / top|left|right|bottom / border-radius)
# font-size, layout widths, and @media breakpoints are intentionally NOT flagged — they aren't on the 4px scale.
# After applying DESIGN.md this should be quiet. Non-zero exit = raw colors found.

param(
  [Parameter(Mandatory = $true)][string]$Path
)

if (-not (Test-Path $Path)) { Write-Error "File not found: $Path"; exit 1 }

$lines = Get-Content -LiteralPath $Path
$allowedPx = @(0, 1, 2, 4, 6, 8, 10, 12, 14, 16, 24, 28, 30)
$spacingProp = 'padding|margin|gap|inset|top|left|right|bottom|border-radius|border-width'

$inStyle = $false
$inRoot = $false
$colorHits = @()
$pxHits = @()

for ($i = 0; $i -lt $lines.Count; $i++) {
  $line = $lines[$i]
  $n = $i + 1

  if ($line -match '<style') { $inStyle = $true; continue }
  if ($line -match '</style>') { $inStyle = $false; continue }
  if (-not $inStyle) { continue }

  # skip token DEFINITION blocks (:root { } and prefers-color-scheme media)
  if ($line -match ':root' -or ($line -match '@media' -and $line -match 'prefers-color-scheme')) { $inRoot = $true }
  if ($inRoot -and $line -match '\}\s*$') { $inRoot = $false; continue }
  if ($inRoot) { continue }

  $stripped = $line -replace 'var\(--[a-z0-9-]+\)', ''

  if ($stripped -match '#[0-9a-fA-F]{3,8}\b' -or $stripped -match 'rgba?\s*\(') {
    $colorHits += "  line ${n}: $($line.Trim())"
  }

  foreach ($m in [regex]::Matches($stripped, "($spacingProp)\s*:\s*([^;]+)")) {
    foreach ($pm in [regex]::Matches($m.Groups[2].Value, '(?<![\w.])(\d+)px')) {
      $v = [int]$pm.Groups[1].Value
      if ($allowedPx -notcontains $v) {
        $pxHits += "  line ${n}: ${v}px in $($m.Groups[1].Value)  ->  $($line.Trim())"
      }
    }
  }
}

Write-Host "== $Path ==" -ForegroundColor Cyan
Write-Host ""
Write-Host "Raw color literals in CSS rules ($($colorHits.Count)):" -ForegroundColor Yellow
if ($colorHits) { $colorHits | ForEach-Object { Write-Host $_ } } else { Write-Host "  (none - good)" -ForegroundColor Green }
Write-Host ""
Write-Host "Off-scale px in spacing properties ($($pxHits.Count)):" -ForegroundColor Yellow
if ($pxHits) { $pxHits | ForEach-Object { Write-Host $_ } } else { Write-Host "  (none - good)" -ForegroundColor Green }
Write-Host ""

if ($colorHits.Count -gt 0) { exit 1 } else { exit 0 }
