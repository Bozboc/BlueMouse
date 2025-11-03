# Bluetooth HID Test Script
# This script monitors adb logcat for Bluetooth HID events and tests functionality

param(
    [string]$DeviceId = "10BF851QA8002FR",
    [switch]$ClearLogs = $true
)

Write-Host "=== Bluetooth HID Test Monitor ===" -ForegroundColor Cyan
Write-Host "Device: $DeviceId" -ForegroundColor Yellow
Write-Host ""

# Clear logcat if requested
if ($ClearLogs) {
    Write-Host "Clearing logcat buffer..." -ForegroundColor Gray
    adb -s $DeviceId logcat -c
    Start-Sleep -Milliseconds 500
}

Write-Host "Monitoring for Bluetooth HID events..." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Yellow

# Function to format log entry
function Format-LogEntry {
    param($Line)
    
    if ($Line -match "BluetoothHid") {
        Write-Host $Line -ForegroundColor Cyan
    }
    elseif ($Line -match "ERROR|Exception|error") {
        Write-Host $Line -ForegroundColor Red
    }
    elseif ($Line -match "sendKeyPress|sendMouseMove|sendConsumerKey") {
        Write-Host $Line -ForegroundColor Green
    }
    elseif ($Line -match "pcremote|pc_remote") {
        Write-Host $Line -ForegroundColor Yellow
    }
    else {
        Write-Host $Line
    }
}

# Start monitoring
try {
    adb -s $DeviceId logcat | Where-Object {
        $_ -match "pcremote" -or 
        $_ -match "BluetoothHid" -or 
        $_ -match "pc_remote" -or
        $_ -match "flutter" -or
        $_ -match "SecurityException"
    } | ForEach-Object {
        Format-LogEntry $_
    }
}
catch {
    Write-Host "`nMonitoring stopped" -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Red
}
