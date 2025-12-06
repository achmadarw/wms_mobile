# WMS Mobile Log Filter
# Filter hanya log aplikasi WMS, buang system noise (gralloc4, dll)

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "WMS Mobile Log Filter" -ForegroundColor Cyan
Write-Host "Memfilter log aplikasi WMS saja..." -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Run flutter dan filter output
flutter run --hot | Select-String -Pattern "WMS-|═════" -CaseSensitive | ForEach-Object {
    $line = $_.Line
    
    # Colorize berdasarkan tipe log
    if ($line -match "WMS-UI-") {
        Write-Host $line -ForegroundColor Green
    }
    elseif ($line -match "WMS-PROVIDER") {
        Write-Host $line -ForegroundColor Yellow
    }
    elseif ($line -match "WMS-SERVICE|WMS-AUTH-SERVICE") {
        Write-Host $line -ForegroundColor Cyan
    }
    elseif ($line -match "❌|ERROR|Failed") {
        Write-Host $line -ForegroundColor Red
    }
    elseif ($line -match "✅|SUCCESS|successful") {
        Write-Host $line -ForegroundColor Green
    }
    elseif ($line -match "═════") {
        Write-Host $line -ForegroundColor DarkGray
    }
    else {
        Write-Host $line
    }
}
