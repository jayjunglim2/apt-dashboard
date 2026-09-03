<#  간단 정적 서버 (로컬 미리보기용).  powershell -ExecutionPolicy Bypass -File scripts\serve.ps1  #>
param([int]$Port = 8765, [string]$Root = "$PSScriptRoot\..")
$Root = (Resolve-Path $Root).Path
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "serving $Root at http://localhost:$Port/  (Ctrl+C to stop)"
$mime = @{ '.html'='text/html; charset=utf-8'; '.js'='text/javascript'; '.css'='text/css';
          '.json'='application/json; charset=utf-8'; '.csv'='text/csv'; '.png'='image/png'; '.svg'='image/svg+xml' }
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  try {
    $rel = [uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart('/')
    if ($rel -eq '') { $rel = 'index.html' }
    $path = Join-Path $Root $rel
    if (Test-Path $path -PathType Leaf) {
      $bytes = [System.IO.File]::ReadAllBytes($path)
      $ext = [System.IO.Path]::GetExtension($path).ToLower()
      if ($mime.ContainsKey($ext)) { $ctx.Response.ContentType = $mime[$ext] }
      $ctx.Response.Headers.Add('Access-Control-Allow-Origin','*')
      $ctx.Response.OutputStream.Write($bytes,0,$bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
      $b = [Text.Encoding]::UTF8.GetBytes("404: $rel")
      $ctx.Response.OutputStream.Write($b,0,$b.Length)
    }
  } catch { }
  $ctx.Response.Close()
}
