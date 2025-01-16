# PowerShell script for managing Dell Command Update

function Show-Menu {
    Write-Host "Please select an option:" -ForegroundColor Cyan
    Write-Host "1. Install Dell Command Update"
    Write-Host "2. Configure Schedule"
    Write-Host "3. Install Drivers"
    Write-Host "4. Install All Updates"
    Write-Host "0. Exit"
}

function Install-DellCommandUpdate {
    Write-Host "Installing Dell Command Update..." -ForegroundColor Yellow
    winget install Dell.CommandUpdate --scope machine --accept-package-agreements --accept-source-agreements
    Write-Host "Dell Command Update installation completed." -ForegroundColor Green
}

function Configure-Schedule {
    Write-Host "Configuring schedule for Dell Command Update..." -ForegroundColor Yellow
    & "c:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" /configure -scheduleAuto -scheduleAction=DownloadInstallAndNotify
    Write-Host "Schedule configuration completed." -ForegroundColor Green
}

function Install-Drivers {
    Write-Host "Installing drivers using Dell Command Update..." -ForegroundColor Yellow
    & "c:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" /driverInstall
    Write-Host "Driver installation completed." -ForegroundColor Green
}

function Apply-AllUpdates {
    Write-Host "Applying all updates using Dell Command Update..." -ForegroundColor Yellow
    & "c:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" /applyUpdates
    Write-Host "All updates applied." -ForegroundColor Green
}

do {
    Clear-Host
    Show-Menu
    $choice = Read-Host "Enter your choice (0-4)"

    switch ($choice) {
        "1" { Install-DellCommandUpdate }
        "2" { Configure-Schedule }
        "3" { Install-Drivers }
        "4" { Apply-AllUpdates }
        "0" { Write-Host "Exiting the script. Goodbye!" -ForegroundColor Green }
        default { Write-Host "Invalid option, please try again." -ForegroundColor Red }
    }

    if ($choice -ne "0") {
        Read-Host "Press Enter to return to the menu..."
    }

} while ($choice -ne "0")
