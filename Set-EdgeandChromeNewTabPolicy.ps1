# Check if Edge key exists
$EdgeRegKey = 'HKLM:\Software\Policies\Microsoft\Edge'
If ( -Not (Test-Path $EdgeRegKey)) {
  New-Item -Path $EdgeRegKey -Force | Out-Null
}
# Set new tab page background
New-ItemProperty -Path $EdgeRegKey -Name "NewTabPageAllowedBackgroundTypes" -Value "3" -PropertyType DWORD -Force | Out-Null
# Set new tab page content to Off
New-ItemProperty -Path $EdgeRegKey -Name "NewTabPageContentEnabled" -Value "0" -PropertyType DWORD -Force | Out-Null
# Hide default top sites
New-ItemProperty -Path $EdgeRegKey -Name "NewTabPageHideDefaultTopSites" -Value "1" -PropertyType DWORD -Force | Out-Null
# Disable new tab page quick links
New-ItemProperty -Path $EdgeRegKey -Name "NewTabPageQuickLinksEnabled" -Value "0" -PropertyType DWORD -Force | Out-Null


# Check if Chrome key exist
$ChromeRegKey = 'HKLM:\Software\Policies\Google\Chrome'
If ( -Not (Test-Path $ChromeRegKey)) {
  New-Item -Path $ChromeRegKey -Force | Out-Null
}
# Set new tab page URL to www.google.com
New-ItemProperty -Path $ChromeRegKey -Name "NewTabPageLocation" -Value "www.google.com" -PropertyType STRING -Force | Out-Null
