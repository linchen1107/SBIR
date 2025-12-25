# 詳細資料比對腳本
$psql = "C:\Program Files\PostgreSQL\16\bin\psql.exe"
$dbName = "sbir_equipment_db_v3"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "開始詳細比對 Users 資料" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 提取 SQL 檔案中的 users 資料
$usersLines = Select-String -Path "C:\github\SBIR\Database\export\20251219.sql" -Pattern "^INSERT INTO web_app\.users"

Write-Host "`n找到 $($usersLines.Count) 筆 users INSERT 語句`n" -ForegroundColor Yellow

# 逐筆比對
foreach ($line in $usersLines) {
    # 提取 ID
    if ($line.Line -match "VALUES \('([^']+)'::uuid, '([^']+)', '([^']+)',") {
        $id = $matches[1]
        $username = $matches[2]
        $email = $matches[3]
        
        Write-Host "比對使用者: $username (ID: $id)" -ForegroundColor Green
        
        # 從資料庫查詢此使用者的完整資料
        $query = @"
SELECT 
    id::text,
    username,
    email,
    CASE WHEN password_hash IS NOT NULL THEN 'EXISTS' ELSE 'NULL' END as pwd,
    english_code,
    full_name,
    department,
    position,
    phone,
    role,
    is_active::text,
    is_verified::text,
    email_verified_at::text,
    last_login_at::text,
    failed_login_attempts::text,
    CASE WHEN locked_until IS NOT NULL THEN locked_until::text ELSE 'NULL' END as locked_until,
    date_created::text,
    date_updated::text
FROM web_app."User"
WHERE id = '$id';
"@
        
        $dbData = $query | & $psql -U postgres -d $dbName -t -A -F "|"
        
        if ($dbData) {
            Write-Host "   資料庫中找到此使用者" -ForegroundColor Green
            Write-Host "  DB: $dbData" -ForegroundColor Gray
        } else {
            Write-Host "   資料庫中找不到此使用者！" -ForegroundColor Red
        }
        Write-Host ""
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "開始詳細比對 Applications 資料" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 提取 SQL 檔案中的 applications ID
$appLines = Select-String -Path "C:\github\SBIR\Database\export\20251219.sql" -Pattern "^INSERT INTO web_app\.applications"

Write-Host "`n找到 $($appLines.Count) 筆 applications INSERT 語句`n" -ForegroundColor Yellow

$appIds = @()
foreach ($line in $appLines) {
    if ($line.Line -match "VALUES \('([^']+)'::uuid") {
        $appIds += $matches[1]
    }
}

Write-Host "SQL 檔案中的 Application IDs: $($appIds.Count) 筆" -ForegroundColor Yellow

# 從資料庫查詢所有 application IDs
$query = "SELECT id::text FROM old_data.applications ORDER BY id;"
$dbAppIds = ($query | & $psql -U postgres -d $dbName -t | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })

Write-Host "資料庫中的 Application IDs: $($dbAppIds.Count) 筆`n" -ForegroundColor Yellow

# 比對 IDs
$sqlSet = [System.Collections.Generic.HashSet[string]]::new($appIds)
$dbSet = [System.Collections.Generic.HashSet[string]]::new($dbAppIds)

$missing = [System.Collections.Generic.List[string]]::new()
foreach ($id in $sqlSet) {
    if (-not $dbSet.Contains($id)) {
        $missing.Add($id)
    }
}

if ($missing.Count -eq 0) {
    Write-Host " 所有 Application ID 都已匯入" -ForegroundColor Green
} else {
    Write-Host " 發現 $($missing.Count) 筆 Application 未匯入：" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "比對完成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
