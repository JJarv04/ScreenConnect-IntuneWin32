# ScreenConnect Install Wrapper for generic use.
# James Vincent
# February 2024
# Modified: JJA Sept 2024

# Example
# .\Install-ScreenConnect.ps1 -BaseUrl 'https://example.com' -Client "Staff Laptop" -Department "No Consent" -DeviceType "No Consent"
# .\Install-ScreenConnect.ps1 -BaseUrl 'https://example.com' -Client "Staff Laptop" -LogDirectory 'C:\Logs'

param (
    [Parameter(Mandatory = $true)]
    [string]$BaseURL,
    [Parameter(Mandatory = $true)]
    [string]$Client,
    [Parameter(Mandatory = $false)]
    [string]$Department,
    [Parameter(Mandatory = $false)]
    [string]$DeviceType,
    [Parameter(Mandatory = $false)]
    [string]$LogDirectory
)

if ($LogDirectory) {
    Start-Transcript -Path "$LogDirectory\Install-Screenconnect.log" -Append -Force | Out-Null
}

# Create new temp directory to download and install from.
$FolderPath = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString()) -Force
$FolderPath = $FolderPath.FullName

# Set the msi installer log path
if ($LogDirectory) {
    $MSILogPath = $LogDirectory
}
else {
    $MSILogPath = $FolderPath
}

# Install ScreenConnect
Invoke-WebRequest "$BaseURL/Bin/ScreenConnect.ClientSetup.msi?e=Access&y=Guest&c=$Client&c=&c=$Department&c=$DeviceType&c=&c=&c=&c=" -OutFile $FolderPath\ScreenConnect.msi -TimeoutSec 240 -UseBasicParsing 

Start-Process "msiexec.exe" -ArgumentList "/i", "$FolderPath\ScreenConnect.msi", "/qn", "/l*v", "`"$MSILogPath\App-Install-ScreenConnect.log`"" -Wait | Out-Null

# Delete the ScreenConnect Installer
$FilePath = "$FolderPath\ScreenConnect.msi"
if (!(Test-Path $FilePath)) {
    Write-host "$FilePath not found."
}
else {
    Remove-Item -LiteralPath $FolderPath -Force -Recurse | Out-Null
}

if ($LogDirectory) {
    Stop-Transcript | Out-Null
}
exit 0

