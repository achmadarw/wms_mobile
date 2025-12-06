# WMS Mobile Log Filter - SIMPLE VERSION
# Filter hanya log WMS, save ke file

$logFile = "wms-logs-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "WMS Mobile Log Filter" -ForegroundColor Cyan
Write-Host "Log akan disimpan ke: $logFile" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Run flutter dan filter + save
flutter run --hot 2>&1 | ForEach-Object {
    $line = $_.ToString()
    
    # Hanya tampilkan dan simpan log WMS
    if ($line -match "WMS-|═════") {
        # Tampilkan di console
        if ($line -match "❌|ERROR") {
            Write-Host $line -ForegroundColor Red
        }
        elseif ($line -match "✅|SUCCESS") {
            Write-Host $line -ForegroundColor Green
        }
        elseif ($line -match "WMS-UI-") {
            Write-Host $line -ForegroundColor Green
        }
        elseif ($line -match "WMS-PROVIDER") {
            Write-Host $line -ForegroundColor Yellow
        }
        elseif ($line -match "WMS-SERVICE|WMS-AUTH") {
            Write-Host $line -ForegroundColor Cyan
        }
        else {
            Write-Host $line
        }
        
        # Simpan ke file
        $line | Out-File -Append -FilePath $logFile -Encoding UTF8
    }
    # Tampilkan critical messages (error, build status)
    elseif ($line -match "Error:|Exception:|Built|Installing|Launching|Hot reload|Hot restart") {
        Write-Host $line -ForegroundColor White
    }
}
