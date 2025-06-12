# ScreenConnect Install Wrapper for Intune
# James Vincent
# February 2024
# Modified: JJA Sept 2024

#! Define the URL for the ScreenConnect server
$scBaseUrl = 'https://support.example.com/'

#! If you want to log the output of this script, set this to $true
$doTranscribe = $true

#! Define the Path For loging output on the client device 
$logDirectory = "C:\Logs"

#=================================================================================================
# Script =========================================================================================

if ($doTranscribe) {
    Start-Transcript -Path "$logDirectory\Detect-Screenconnect.log" -Append -Force
}

# Define the application name
$applicationName = "ScreenConnect Client"

# Whether we should check the version of the client installed matches the SC Server version.
$versionCheck = $false

# Function to get the GUID from the uninstall string
function Get-GuidFromUninstallString($uninstallString) {
    $uninstallString -match '\{(.+?)\}' | Out-Null; $Matches[1]
}

# Search 64-bit registry
$uninstallKey64 = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" |
Where-Object { $_.DisplayName -like "*$applicationName*" }

# Search 32-bit registry
$uninstallKey32 = Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
Where-Object { $_.DisplayName -like "*$applicationName*" }

# Here we make a request to the SC Server and parse out the server version from the one of the available pages.
try {
    #! Old header method - Seemingly patched or removed while reverse proxying perhaps?
    # $supportHeaders = Invoke-WebRequest -method Get -uri $scBaseUrl -TimeoutSec 240 -UseBasicParsing | Select-Object -ExpandProperty Headers
    # $scServerString = [string] $supportHeaders.Server -match "(?<server>ScreenConnect\/(?<version>\d{1,4}.\d{1,4}.\d{1,4}.\d{1,4})-\d+).*"

    $supportPage = Invoke-WebRequest -method Get -uri "$scBaseUrl/Script.ashx" -TimeoutSec 240 -UseBasicParsing | Select-Object -ExpandProperty content
    $scServerString = [string] $supportPage -match  "productVersion`":`"(?<version>\d+\.\d+\.\d+\.\d+)"

    if ($null -ne $scServerVersion) {
        $versionCheck = $true
    }
}
catch {
    # If this fails for whatever reason we should fallback on just a general check to see if SC is installed & not worry about the version check.
    $versionCheck = $false
    continue
}

try {
    # Using reg key, check for installation presence and version check if neccesary
    if ($uninstallKey64) {
        $displayName = $uninstallKey64.DisplayName
        if (!$versionCheck) {
            Write-Output "$displayName is Installed"
            exit 0
        }
    
        # Check if the installed version of SC is at or above the server version.
        $displayVersion = $uninstallKey64.DisplayVersion
        if ([version] $displayVersion -ge $scServerVersion) {
            Write-Output "$displayName is Installed and satisfies SC Server Version (Host:$displayVersion | Server:$scServerVersion)"
            exit 0
        }
        else {
            Write-Output "$displayName is Installed but does not satisfy SC Server Version (Host:$displayVersion | Server:$scServerVersion)"
            exit 1
        }
    } elseif ($uninstallKey32) {
        $displayName = $uninstallKey32.DisplayName
        if (!$versionCheck) {
            Write-Output "$displayName is Installed"
            exit 0
        }
        
        # Check if the installed version of SC is at or above the server version.
        $displayVersion = $uninstallKey32.DisplayVersion
        if ([version] $displayVersion -ge $scServerVersion) {
            Write-Output "$displayName is Installed and satisfies SC Server Version (Host:$displayVersion | Server:$scServerVersion)"
            exit 0
        }
        else {
            Write-Output "$displayName is Installed but does not satisfy SC Server Version (Host:$displayVersion | Server:$scServerVersion)"
            exit 1
        }
    } else {
        Write-Output "Application not detected"
        exit 1
    }
}
finally {
    if ($doTranscribe) {
        Stop-Transcript | Out-Null
    }
}
