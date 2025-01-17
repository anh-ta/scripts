# Script to install applications using WinGet
# Author: Your Name
# Date: YYYY-MM-DD

# Define applications in an array of hashtables for easy maintenance
$applications = @(
    @{
        Name = "Adobe Reader"
        PackageName = "Adobe.Acrobat.Reader.64-bit"
    },
    @{
        Name = "Greenshot"
        PackageName = "Greenshot.Greenshot"
    },
    @{
        Name = "Power BI Desktop"
        PackageName = "Microsoft.PowerBI"
    },
    @{
        Name = "VS Code"
        PackageName = "vscode"
    }
)

# Sort applications alphabetically by name
$applications = $applications | Sort-Object -Property Name

function Show-Menu {
    Write-Host "Application Installation Menu"
    Write-Host "========================================="
    $i = 1
    foreach ($app in $applications) {
        Write-Host "$i. $($app.Name)"
        $i++
    }
    Write-Host "0. Exit"
    Write-Host "========================================="
}

function Install-Application {
    param (
        [int]$index
    )
    if ($index -ge 1 -and $index -le $applications.Count) {
        $app = $applications[$index - 1]
        Write-Host "Installing $($app.Name)..."
        $command = "winget install $($app.PackageName) --scope machine --accept-package-agreements --accept-source-agreements"
        Invoke-Expression $command
    } else {
        Write-Host "Invalid selection. Please try again."
    }
}

# Main loop
do {
    Show-Menu
    $choice = Read-Host "Enter your choice (number):"
    if ($choice -eq 0) {
        Write-Host "Exiting script. Goodbye!"
        break
    } elseif ($choice -match "^\d+$") {
        Install-Application -index [int]$choice
    } else {
        Write-Host "Invalid input. Please enter a number."
    }
} while ($true)
