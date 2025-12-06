# Quick WMS Log Viewer
# Hanya tampilkan log WMS dari flutter run yang sudah jalan

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "WMS Log Viewer (Live)" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Monitor logcat langsung dari Android device
adb logcat -v time flutter:I *:S | Select-String -Pattern "WMS-|═════" | ForEach-Object {
    $line = $_.Line
    
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
}
