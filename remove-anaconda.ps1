# Function to check and remove .condarc file
function Check-AndRemove-Condarc {
    $condaConfigPath = "$env:USERPROFILE\.condarc"
    if (Test-Path -Path $condaConfigPath) {
        Write-Host "The .condarc file is located at: $condaConfigPath" -ForegroundColor Yellow
        Remove-Item -Path $condaConfigPath -Force
        Write-Host ".condarc file has been deleted." -ForegroundColor Green
    } else {
        Write-Host ".condarc file not found." -ForegroundColor Red
    }
}
 
# Function to check and remove .conda directory
function Check-AndRemove-CondaDir {
    $condaDirPath = "$env:USERPROFILE\.conda"
    if (Test-Path -Path $condaDirPath) {
        Write-Host "The .conda directory is located at: $condaDirPath" -ForegroundColor Yellow
        Remove-Item -Path $condaDirPath -Recurse -Force
        Write-Host ".conda directory has been deleted." -ForegroundColor Green
    } else {
        Write-Host ".conda directory not found." -ForegroundColor Red
    }
}
 
# Function to check and remove .continuum directory
function Check-AndRemove-Continuum {
    $continuumPath = "$env:USERPROFILE\.continuum"
    if (Test-Path -Path $continuumPath) {
        Write-Host "The .continuum directory is located at: $continuumPath" -ForegroundColor Yellow
        Remove-Item -Path $continuumPath -Recurse -Force
        Write-Host ".continuum directory has been deleted." -ForegroundColor Green
    } else {
        Write-Host ".continuum directory not found." -ForegroundColor Red
    }
}
 
# Function to check and remove conda executable and packages
function Check-AndRemove-Conda {
    $conda = Get-Command conda -ErrorAction SilentlyContinue
    if ($conda) {
        Write-Host "Conda executable located at: $($conda.Source)" -ForegroundColor Yellow
        Write-Host "Removing conda packages and executable..." -ForegroundColor Yellow
        conda install anaconda-clean -y
        anaconda-clean --yes
        Remove-Item -Path $conda.Source -Force
        Write-Host "Conda has been removed." -ForegroundColor Green
    } else {
        Write-Host "Conda is not installed or not found in PATH." -ForegroundColor Red
    }
}
 
# Run all checks and removals
Write-Host "Checking and removing Anaconda repositories, packages, and source files..." -ForegroundColor Cyan
Check-AndRemove-Condarc
Check-AndRemove-CondaDir
Check-AndRemove-Continuum
Check-AndRemove-Conda
Write-Host "Check and removal process complete." -ForegroundColor Cyan
