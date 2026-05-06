$ErrorActionPreference = "Stop"

$envPath = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envPath)) {
  throw "لم أجد ملف .env بجانب هذا السكربت."
}

$password = Read-Host "اكتب كلمة سر قاعدة بيانات Supabase"
if ([string]::IsNullOrWhiteSpace($password)) {
  throw "كلمة السر فارغة."
}

$databaseUrl = "DATABASE_URL=`"postgresql://postgres.hdvpolaocicwbtnpdszn:$password@aws-1-eu-central-1.pooler.supabase.com:6543/postgres?pgbouncer=true`""
$directUrl = "DIRECT_URL=`"postgresql://postgres.hdvpolaocicwbtnpdszn:$password@aws-1-eu-central-1.pooler.supabase.com:5432/postgres`""

$content = Get-Content -Path $envPath -Raw

if ($content -match "(?m)^DATABASE_URL=") {
  $content = [regex]::Replace($content, "(?m)^DATABASE_URL=.*$", $databaseUrl)
} else {
  $content = $databaseUrl + "`r`n" + $content
}

if ($content -match "(?m)^DIRECT_URL=") {
  $content = [regex]::Replace($content, "(?m)^DIRECT_URL=.*$", $directUrl)
} else {
  $content = $directUrl + "`r`n" + $content
}

Set-Content -Path $envPath -Value $content -Encoding UTF8

Write-Host ""
Write-Host "تم حفظ كلمة السر في .env بنجاح." -ForegroundColor Green
Write-Host "يمكنك الآن الرجوع إلى Codex وكتابة: تم الحفظ" -ForegroundColor Cyan
Read-Host "اضغط Enter للإغلاق"
