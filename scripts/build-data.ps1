<#
  build-data.ps1
  원본 서울 아파트 실거래 CSV -> 서남권 신혼부부 전세/반전세 슬림 JSON

  사용법:
    1) 원본 CSV를 scripts\ 폴더 옆이나 임의 경로에 내려받는다.
       (예: https://raw.githubusercontent.com/ggplab/claude-playbook/main/01-hanbit-claude-guidebook/chap5/seoul-apt-latest.csv )
    2) powershell -ExecutionPolicy Bypass -File scripts\build-data.ps1 -CsvPath <원본csv경로>
    3) data\southwest-rent.json 이 생성/갱신된다.

  규칙 (PRD v0.2):
    - 대상 구: 구로/금천/영등포/관악
    - 전세  : deal_type == 전세
    - 반전세: deal_type == 월세 AND monthly_rent > 0 AND deposit >= 10000 (보증금 1억 이상)
    - 영등포구 세부 법정동(가)은 대표 동으로 통합
    - 금액 단위: 만원
#>
param(
  [string]$CsvPath = "$PSScriptRoot\seoul-apt-latest.csv",
  [string]$OutPath = "$PSScriptRoot\..\data\southwest-rent.json"
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path $CsvPath)) { throw "원본 CSV를 찾을 수 없습니다: $CsvPath" }

$targetGu = '구로구','금천구','영등포구','관악구'
$rows = Import-Csv -Path $CsvPath

$types = @{}    # 유형 인덱스
$yms   = @{}    # 계약연월 인덱스
$typeList = New-Object System.Collections.ArrayList
$ymList   = New-Object System.Collections.ArrayList

function Idx($map, $list, $key) {
  if (-not $map.ContainsKey($key)) { $map[$key] = $list.Add($key) }
  return $map[$key]
}

$out = New-Object System.Collections.ArrayList
foreach ($r in $rows) {
  if ($targetGu -notcontains $r.gu) { continue }

  $deposit = 0; [void][int]::TryParse($r.deposit, [ref]$deposit)
  $rent    = 0; [void][int]::TryParse($r.monthly_rent, [ref]$rent)

  $kind = $null
  if ($r.deal_type -eq '전세') { $kind = '전세' }
  elseif ($r.deal_type -eq '월세' -and $rent -gt 0 -and $deposit -ge 10000) { $kind = '반전세' }
  else { continue }

  # 영등포구 세부 동 통합: '당산동4가' -> '당산동'
  $dong = $r.dong
  if ($r.gu -eq '영등포구') { $dong = $dong -replace '[0-9]+가$','' }

  $area = 0.0; [void][double]::TryParse($r.area_m2, [ref]$area)
  $floor = 0; [void][int]::TryParse($r.floor, [ref]$floor)

  [void]$out.Add(@(
    $r.gu,
    $dong,
    $r.complex,
    [math]::Round($area,1),
    $floor,
    (Idx $types $typeList $kind),
    $deposit,
    $rent,
    (Idx $yms $ymList $r.contract_ym)
  ))
}

$payload = [ordered]@{
  meta = [ordered]@{
    generatedAt = (Get-Date).ToString('yyyy-MM-dd')
    source      = 'MOLIT 아파트 실거래가 (seoul-apt-latest.csv)'
    note        = '과거 실거래 내역이며 현재 매물이 아님. 금액 단위 만원.'
    ymRange     = @(($ymList | Sort-Object)[0], ($ymList | Sort-Object)[-1])
    count       = $out.Count
    rule        = '전세 전체 + 반전세(월세 & 보증금>=1억)'
  }
  cols  = @('gu','dong','complex','area_m2','floor','type','deposit','monthly_rent','ym')
  types = $typeList
  yms   = $ymList
  rows  = $out
}

$dir = Split-Path $OutPath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
$json = $payload | ConvertTo-Json -Depth 6 -Compress
$noBom = New-Object System.Text.UTF8Encoding($false)
$leaf  = Split-Path $OutPath -Leaf
$dirR  = (Resolve-Path $dir).Path
[System.IO.File]::WriteAllText((Join-Path $dirR $leaf), $json, $noBom)
# file:// 로 그냥 열어도 동작하도록 JS 전역 버전도 같이 생성
[System.IO.File]::WriteAllText((Join-Path $dirR ($leaf -replace '\.json$','.js')), "window.SW_RENT = $json;", $noBom)

# dong-info.json -> dong-info.js 동기화
$dongJson = Join-Path $dirR 'dong-info.json'
if (Test-Path $dongJson) {
  $dongRaw = [System.IO.File]::ReadAllText($dongJson, [System.Text.Encoding]::UTF8)
  [System.IO.File]::WriteAllText((Join-Path $dirR 'dong-info.js'), "window.SW_DONG = $dongRaw;", $noBom)
  Write-Host "dong-info.js 동기화 완료"
}

Write-Host ("완료: {0}건 -> {1} (+ .js)" -f $out.Count, (Resolve-Path $OutPath))
