$RemovableStorageDevicesKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices'
if (Test-Path -Path "$RemovableStorageDevicesKey\Deny_All") {
    Set-ItemProperty -Path $RemovableStorageDevicesKey -Name "Deny_All" -Value 1 -Type DWORD -Force | Out-Null

} else {
    Write-Host "Deny_All value does not exist"
    New-ItemProperty -Path $RemovableStorageDevicesKey -Name "Deny_All" -Value 1 -PropertyType DWORD -Force | Out-Null
}


# Check if USBSTOR key exists
$UsbStorKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR'
if (Test-Path -Path "$UsbStorKey\Start") {
    Set-ItemProperty -Path $UsbStorKey -Name "Start" -Value 4 -Type DWORD -Force | Out-Null

} else {

    New-ItemProperty -Path $UsbStorKey -Name "Start" -Value 4 -PropertyType DWORD -Force | Out-Null
}
