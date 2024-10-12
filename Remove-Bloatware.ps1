# PowerShell Script to Remove Bloatware and Built-in Games on Windows 11

# Function to Remove a Specific App
function Remove-AppxPackageByName {
    param (
        [string]$appName
    )
    
    # Validate app name
    if (-not $appName) {
        Write-Error "App name cannot be null or empty."
        return
    }

    try {
        # Remove for current user
        Write-Output "Removing $appName for current user..."
        Get-AppxPackage -Name $appName -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue

        # Remove provisioned app (for new users)
        Write-Output "Removing provisioned $appName for new users..."
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $appName | ForEach-Object { 
            Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
        }

        Write-Output "$appName removed successfully."
    } catch {
        Write-Error "Failed to remove $appName: $_"
    }
}

# List of Common Bloatware and Built-in Games to Remove
$bloatwareApps = @(
    # Bloatware apps
    "Microsoft.3DBuilder",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Messaging",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MixedReality.Portal",
    "Microsoft.OneConnect",
    "Microsoft.People",
    "Microsoft.Print3D",
    "Microsoft.SkypeApp",
    "Microsoft.Wallet",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "king.com.CandyCrushSaga",
    "king.com.CandyCrushSodaSaga",
    "king.com.BubbleWitch3Saga",
    "Microsoft.MinecraftUWP",
    "Microsoft.MicrosoftJigsaw",
    "Microsoft.MicrosoftMahjong",
    "Microsoft.MicrosoftSudoku",
    "Microsoft.MicrosoftUltimateWordGames"
)

# Loop through each app and remove it
foreach ($app in $bloatwareApps) {
    Write-Host "Removing $app..." -ForegroundColor Cyan
    Remove-AppxPackageByName -appName $app
}

# Clean up remaining Xbox-related services
Write-Host "Removing Xbox Services..." -ForegroundColor Cyan
Get-AppxPackage *xbox* -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxProvisionedPackage -Online | Where-Object DisplayName -match "xbox" | ForEach-Object {
    Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
}

# Remove Other Specific Services
Write-Host "Removing other specific bloatware services..." -ForegroundColor Cyan
Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*OneNote*" -or $_.Name -like "*News*" -or $_.Name -like "*Weather*" -or $_.Name -like "*Game*" } | ForEach-Object {
    $_ | Remove-AppxPackage -ErrorAction SilentlyContinue
}

Write-Host "All specified bloatware and built-in games have been removed." -ForegroundColor Green
