$RemovableStorageDevicesKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices'
Set-ItemProperty -Path $RemovableStorageDevicesKey -Name "Deny_All" -Value 1 -Type DWORD -Force | Out-Null

$UsbStorKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR'
Set-ItemProperty -Path $UsbStorKey -Name "Start" -Value 4 -Type DWORD -Force | Out-Null
