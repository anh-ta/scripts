$RemovableStorageDevicesKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices'
if (-not (Test-Path $RemovableStorageDevicesKey)) {
    New-Item -Path $RemovableStorageDevicesKey -Force | Out-Null
}
Set-ItemProperty -Path $RemovableStorageDevicesKey -Name "Deny_All" -Value 1 -Type DWORD -Force | Out-Null



$UsbStorKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR'
if (-not (Test-Path $UsbStorKey)) {
    New-Item -Path $UsbStorKey -Force | Out-Null
}
Set-ItemProperty -Path $UsbStorKey -Name "Start" -Value 4 -Type DWORD -Force | Out-Null
