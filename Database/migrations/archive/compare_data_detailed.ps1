# 資料庫詳細比對腳本
# 比對 SQL 檔案與資料庫中的所有資料

$env:PGPASSWORD = "willlin07"
$psql = "C:\Program Files\PostgreSQL\16\bin\psql.exe"
$db = "sbir_equipment_db_v3"
$sqlFile = "C:\github\SBIR\Database\export\20251219.sql"
$outputDir = "C:\github\SBIR\Database\migrations"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "開始詳細資料比對" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 1. 比對 Users 數量
Write-Host "[1/10] 比對使用者數量..." -ForegroundColor Yellow
$sqlUserCount = (Select-String -Path $sqlFile -Pattern "^INSERT INTO web_app\.users").Count
$dbUserCount = (& $psql -U postgres -d $db -t -A -c 'SELECT COUNT(*) FROM web_app."User";').Trim()

Write-Host "  SQL 檔案: $sqlUserCount 個使用者" -ForegroundColor Gray
Write-Host "  資料庫:   $dbUserCount 個使用者" -ForegroundColor Gray

if ($sqlUserCount -eq $dbUserCount) {
    Write-Host "  ✓ 使用者數量一致" -ForegroundColor Green
} else {
    Write-Host "  ✗ 使用者數量不一致" -ForegroundColor Red
    Write-Host "  差異: $($sqlUserCount - $dbUserCount)" -ForegroundColor Red
}
Write-Host ""

# 2. 提取並比對每個使用者的詳細資料
Write-Host "[2/10] 提取SQL檔案中的使用者ID..." -ForegroundColor Yellow
$sqlUserIDs = @()
Select-String -Path $sqlFile -Pattern "^INSERT INTO web_app\.users" | ForEach-Object {
    if ($_.Line -match "'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})'::uuid") {
        $sqlUserIDs += $matches[1]
    }
}
Write-Host "  提取到 $($sqlUserIDs.Count) 個使用者ID" -ForegroundColor Gray
Write-Host ""

Write-Host "[3/10] 提取資料庫中的使用者ID..." -ForegroundColor Yellow
$dbUserIDsRaw = & $psql -U postgres -d $db -t -A -c 'SELECT id::text FROM web_app."User" ORDER BY id;'
$dbUserIDs = @($dbUserIDsRaw.Trim() -split "`r?`n")
Write-Host "  提取到 $($dbUserIDs.Count) 個使用者ID" -ForegroundColor Gray
Write-Host ""

Write-Host "[4/10] 比對使用者ID..." -ForegroundColor Yellow
$missingUserIDs = $sqlUserIDs | Where-Object { $_ -notin $dbUserIDs }
$extraUserIDs = $dbUserIDs | Where-Object { $_ -notin $sqlUserIDs }

if ($missingUserIDs.Count -eq 0 -and $extraUserIDs.Count -eq 0) {
    Write-Host "  ✓ 所有使用者ID完全一致" -ForegroundColor Green
} else {
    if ($missingUserIDs.Count -gt 0) {
        Write-Host "  ✗ 資料庫缺少以下使用者:" -ForegroundColor Red
        $missingUserIDs | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
    }
    if ($extraUserIDs.Count -gt 0) {
        Write-Host "  ✗ 資料庫多出以下使用者:" -ForegroundColor Red
        $extraUserIDs | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
    }
}
Write-Host ""

# 3. 比對 Applications 數量
Write-Host "[5/10] 比對申請單數量..." -ForegroundColor Yellow
$sqlAppCount = (Select-String -Path $sqlFile -Pattern "^INSERT INTO web_app\.applications").Count
$dbAppCount = (& $psql -U postgres -d $db -t -A -c 'SELECT COUNT(*) FROM web_app.application;').Trim()

Write-Host "  SQL 檔案: $sqlAppCount 筆申請單" -ForegroundColor Gray
Write-Host "  資料庫:   $dbAppCount 筆申請單" -ForegroundColor Gray

if ($sqlAppCount -eq $dbAppCount) {
    Write-Host "  ✓ 申請單數量一致" -ForegroundColor Green
} else {
    Write-Host "  ✗ 申請單數量不一致" -ForegroundColor Red
    Write-Host "  差異: $($sqlAppCount - $dbAppCount)" -ForegroundColor Red
}
Write-Host ""

# 4. 提取所有申請單ID
Write-Host "[6/10] 提取SQL檔案中的申請單ID..." -ForegroundColor Yellow
$sqlAppIDs = @()
$pattern = "VALUES \('([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})'::uuid"
Select-String -Path $sqlFile -Pattern "^INSERT INTO web_app\.applications" | ForEach-Object {
    if ($_.Line -match $pattern) {
        $sqlAppIDs += $matches[1]
    }
}
Write-Host "  提取到 $($sqlAppIDs.Count) 個申請單ID" -ForegroundColor Gray
$sqlAppIDs | Out-File "$outputDir\sql_app_ids_latest.txt" -Encoding UTF8
Write-Host ""

Write-Host "[7/10] 提取資料庫中的申請單ID..." -ForegroundColor Yellow
& $psql -U postgres -d $db -t -A -c 'SELECT id::text FROM web_app.application ORDER BY id;' | Out-File "$outputDir\db_app_ids_latest.txt" -Encoding UTF8
$dbAppIDsRaw = Get-Content "$outputDir\db_app_ids_latest.txt" -Encoding UTF8
$dbAppIDs = @($dbAppIDsRaw.Trim())
Write-Host "  提取到 $($dbAppIDs.Count) 個申請單ID" -ForegroundColor Gray
Write-Host ""

Write-Host "[8/10] 比對申請單ID..." -ForegroundColor Yellow
$missingAppIDs = $sqlAppIDs | Where-Object { $_ -notin $dbAppIDs }
$extraAppIDs = $dbAppIDs | Where-Object { $_ -notin $sqlAppIDs }

if ($missingAppIDs.Count -eq 0 -and $extraAppIDs.Count -eq 0) {
    Write-Host "  ✓ 所有申請單ID完全一致" -ForegroundColor Green
} else {
    if ($missingAppIDs.Count -gt 0) {
        Write-Host "  ✗ 資料庫缺少以下申請單:" -ForegroundColor Red
        $missingAppIDs | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
        $missingAppIDs | Out-File "$outputDir\missing_app_ids_latest.txt" -Encoding UTF8
    }
    if ($extraAppIDs.Count -gt 0) {
        Write-Host "  ✗ 資料庫多出以下申請單:" -ForegroundColor Red
        $extraAppIDs | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
        $extraAppIDs | Out-File "$outputDir\extra_app_ids_latest.txt" -Encoding UTF8
    }
}
Write-Host ""

# 5. 比對 old_data.applications (遷移前的原始資料)
Write-Host "[9/10] 比對 old_data.applications 資料..." -ForegroundColor Yellow
$oldDataCount = (& $psql -U postgres -d $db -t -A -c 'SELECT COUNT(*) FROM old_data.applications;').Trim()
Write-Host "  old_data.applications: $oldDataCount 筆" -ForegroundColor Gray

# 比對是否所有 old_data 都已遷移到 web_app.application
$unmappedOldData = (& $psql -U postgres -d $db -t -A -c @'
SELECT COUNT(*) 
FROM old_data.applications o
LEFT JOIN web_app.application w ON o.id = w.id
WHERE w.id IS NULL;
'@).Trim()

if ($unmappedOldData -eq "0") {
    Write-Host "  ✓ 所有 old_data 記錄都已遷移" -ForegroundColor Green
} else {
    Write-Host "  ✗ 有 $unmappedOldData 筆 old_data 記錄未遷移" -ForegroundColor Red
}
Write-Host ""

# 6. 總結報告
Write-Host "[10/10] 生成詳細比對報告..." -ForegroundColor Yellow

$report = @"
================================================================================
資料庫詳細比對報告
生成時間: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
================================================================================

1. 使用者資料 (web_app.users / web_app."User")
   - SQL 檔案: $sqlUserCount 個
   - 資料庫:   $dbUserCount 個
   - 狀態: $(if ($sqlUserCount -eq $dbUserCount) { "OK" } else { "NG" })

2. 申請單資料 (web_app.applications / web_app.application)
   - SQL 檔案: $sqlAppCount 筆
   - 資料庫:   $dbAppCount 筆
   - 狀態: $(if ($sqlAppCount -eq $dbAppCount) { "OK" } else { "NG" })
   - 缺少數量: $($missingAppIDs.Count)
   - 多出數量: $($extraAppIDs.Count)

3. 原始資料遷移狀態 (old_data.applications)
   - 總記錄數: $oldDataCount 筆
   - 未遷移:   $unmappedOldData 筆
   - 狀態: $(if ($unmappedOldData -eq "0") { "OK" } else { "NG" })

4. 整體評估
   $(if ($sqlUserCount -eq $dbUserCount -and $sqlAppCount -eq $dbAppCount -and $unmappedOldData -eq "0") {
       "All data matched"
   } else {
       "Data mismatch found"
   })

================================================================================
"@

$report | Out-File "$outputDir\comparison_report.txt" -Encoding UTF8
Write-Host $report -ForegroundColor White

Write-Host ""
Write-Host "比對完成! 報告已儲存至: $outputDir\comparison_report.txt" -ForegroundColor Cyan
